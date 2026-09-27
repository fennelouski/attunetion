//
//  APIClient.swift
//  Attunetion
//
//  API client for backend integration
//

import Foundation
import SwiftData

/// API client for Attunetion backend
@MainActor
class APIClient {
    static let shared = APIClient()
    
    // Configuration - update these when backend is deployed
    var baseURL: String {
        // Check for custom URL in UserDefaults (for testing)
        if let customURL = UserDefaults.standard.string(forKey: "APIBaseURL"), !customURL.isEmpty {
            return customURL
        }
        // Production URL
        return "https://attunetion.vercel.app"
    }
    
    private var apiKey: String? {
        // Check Info.plist first (for production)
        if let key = Bundle.main.object(forInfoDictionaryKey: "APISecretKey") as? String, !key.isEmpty {
            return key
        }
        // Check UserDefaults (for testing/override)
        if let key = UserDefaults.standard.string(forKey: "APISecretKey"), !key.isEmpty {
            return key
        }
        // Return nil if no API key set (backend may allow requests without key for MVP)
        return nil
    }
    
    private let session: URLSession
    
    init(session: URLSession? = nil) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = session ?? URLSession(configuration: configuration)
    }
    
    // MARK: - API Errors

    enum APIError: LocalizedError {
        case invalidURL
        case noBaseURL
        case networkError(Error)
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case decodingError(Error)
        case rateLimitExceeded(retryAfter: TimeInterval?)
        case termsNotAccepted

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .noBaseURL:
                return "The suggestion service is currently unavailable. Please try again later."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            case .httpError(let statusCode, let message):
                return "Server error (\(statusCode)): \(message)"
            case .decodingError(let error):
                return "Failed to parse response: \(error.localizedDescription)"
            case .rateLimitExceeded(let retryAfter):
                if let retryAfter = retryAfter {
                    return "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds."
                }
                return "Rate limit exceeded. Please try again later."
            case .termsNotAccepted:
                return "You must accept the Terms of Service and Privacy Policy before using suggestion features. Please visit Settings > Suggested Intentions to review and accept."
            }
        }
    }

    // MARK: - Request Helpers
    
    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil,
        modelContext: ModelContext? = nil
    ) async throws -> T {
        if endpoint.hasPrefix("ai/") {
            guard let modelContext else { throw ConsentError.termsNotAccepted }
            try ConsentManager.shared.requireConsent(modelContext: modelContext)
        }
        guard !baseURL.isEmpty else {
            throw APIError.noBaseURL
        }
        
        guard let url = URL(string: "\(baseURL)/api/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add API key if available
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
        
        // Add request body if provided
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            if let modelContext {
                try ConsentManager.shared.requireConsent(modelContext: modelContext)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle rate limiting
            if httpResponse.statusCode == 429 {
                let retryAfter: TimeInterval? = {
                    if let retryAfterHeader = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                       let seconds = Double(retryAfterHeader) {
                        return seconds
                    }
                    return nil
                }()
                throw APIError.rateLimitExceeded(retryAfter: retryAfter)
            }
            
            // Handle other HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            // Decode response
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
            
        } catch let error as ConsentError {
            throw error
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - AI Endpoints
    
    /// Generate a theme for an intention
    func generateTheme(intentionText: String, modelContext: ModelContext) async throws -> AITheme {
        struct Request: Encodable {
            let intentionText: String
        }
        
        struct Response: Decodable {
            let theme: AITheme
        }
        
        let response: Response = try await makeRequest(
            endpoint: "ai/generate-theme",
            body: Request(intentionText: intentionText),
            modelContext: modelContext
        )
        
        return response.theme
    }
    
    /// Generate a quote for an intention
    func generateQuote(intentionText: String, modelContext: ModelContext) async throws -> AIQuote {
        struct Request: Encodable {
            let intentionText: String
        }
        
        struct Response: Decodable {
            let quote: String
            let author: String
            let relevance: String
        }
        
        let response: Response = try await makeRequest(
            endpoint: "ai/generate-quote",
            body: Request(intentionText: intentionText),
            modelContext: modelContext
        )
        
        return AIQuote(
            quote: response.quote,
            author: response.author,
            relevance: response.relevance
        )
    }
    
    /// Rephrase an intention
    func rephraseIntention(intentionText: String, previousPhrases: [String] = [], modelContext: ModelContext) async throws -> String {
        struct Request: Encodable {
            let intentionText: String
            let previousPhrases: [String]?
        }
        
        struct Response: Decodable {
            let rephrasedText: String
            let preservedMeaning: Bool
        }
        
        let response: Response = try await makeRequest(
            endpoint: "ai/rephrase-intention",
            body: Request(intentionText: intentionText, previousPhrases: previousPhrases.isEmpty ? nil : previousPhrases),
            modelContext: modelContext
        )
        
        return response.rephrasedText
    }
    
    /// Generate a monthly intention based on previous intentions
    func generateMonthlyIntention(previousIntentions: [PreviousIntention], modelContext: ModelContext) async throws -> String {
        struct Request: Encodable {
            let previousIntentions: [PreviousIntention]
        }
        
        struct Response: Decodable {
            let intention: String
            let reasoning: String
        }
        
        let response: Response = try await makeRequest(
            endpoint: "ai/generate-monthly-intention",
            body: Request(previousIntentions: previousIntentions),
            modelContext: modelContext
        )
        
        return response.intention
    }
    
    /// Check if backend is available
    func checkHealth() async throws -> Bool {
        struct Response: Decodable {
            let status: String
            let timestamp: String
            let version: String
        }
        
        // Use GET for health check
        let response: Response = try await makeRequest(
            endpoint: "health",
            method: "GET"
        )
        
        return response.status == "ok"
    }
    
    /// Generate weekly intentions based on user profile
    func generateWeeklyIntentions(
        userInfo: String,
        weekStartDate: Date,
        previousIntentions: [PreviousIntentionForGeneration] = [],
        modelContext: ModelContext
    ) async throws -> WeeklyIntentionsResponse {
        struct Request: Encodable {
            let userInfo: String
            let weekStartDate: String
            let previousIntentions: [PreviousIntentionForGeneration]?
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        dateFormatter.timeZone = .current
        
        let response: WeeklyIntentionsResponse = try await makeRequest(
            endpoint: "ai/generate-weekly-intentions",
            body: Request(
                userInfo: userInfo,
                weekStartDate: dateFormatter.string(from: weekStartDate),
                previousIntentions: previousIntentions.isEmpty ? nil : previousIntentions
            ),
            modelContext: modelContext
        )
        
        return response
    }
}

// MARK: - Response Models

struct AITheme: Codable {
    let backgroundColor: String
    let textColor: String
    let accentColor: String
    let name: String
    let reasoning: String
}

struct AIQuote: Codable {
    let quote: String
    let author: String
    let relevance: String
}

struct PreviousIntention: Codable {
    let text: String
    let month: String
}

struct PreviousIntentionForGeneration: Codable {
    let text: String
    let scope: String
    let date: String
}

struct WeeklyIntention: Codable {
    let date: String
    let text: String
    let scope: String
}

struct WeeklyIntentionsResponse: Codable {
    let intentions: [WeeklyIntention]
    let weekStartDate: String
    let weekEndDate: String
}



