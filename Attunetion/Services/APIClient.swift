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
    
    /// Stable user/device ID for backend (rate limits, privileged Unsplash access). Persisted in UserDefaults.
    var userId: String {
        let key = "APIClientUserId"
        if let existing = UserDefaults.standard.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    /// Unsplash unlock key (entered in Settings). When valid, user gets unlimited Unsplash access and can submit stable photos to curated.
    var unsplashUnlockKey: String? {
        get { UserDefaults.standard.string(forKey: "UnsplashUnlockKey") }
        set { UserDefaults.standard.set(newValue, forKey: "UnsplashUnlockKey") }
    }

    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil,
        modelContext: ModelContext? = nil,
        queryItems: [URLQueryItem]? = nil,
        includeUserId: Bool = false
    ) async throws -> T {
        if endpoint.hasPrefix("ai/") {
            guard let modelContext else { throw ConsentError.termsNotAccepted }
            try ConsentManager.shared.requireConsent(modelContext: modelContext)
        }
        guard !baseURL.isEmpty else {
            throw APIError.noBaseURL
        }
        
        var urlString = "\(baseURL)/api/\(endpoint)"
        if let queryItems = queryItems, !queryItems.isEmpty {
            var components = URLComponents(string: urlString)
            components?.queryItems = queryItems
            urlString = components?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add API key if available
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
        if includeUserId {
            request.setValue(userId, forHTTPHeaderField: "X-User-Id")
        }
        if let key = unsplashUnlockKey, !key.isEmpty {
            request.setValue(key, forHTTPHeaderField: "X-Unsplash-Unlock-Key")
        }
        
        // Add request body if provided (skip for GET)
        if method != "GET", let body = body {
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
    
    // MARK: - Images (Unsplash / curated)

    /// Get Unsplash access (canSearch, unlimitedThemes). Send X-User-Id and optionally X-Unsplash-Unlock-Key.
    func fetchImagesAccess() async throws -> ImagesAccessResponse {
        try await makeRequest(
            endpoint: "images/access",
            method: "GET",
            includeUserId: true
        )
    }

    /// Fetch curated photos (approved for all users). Optional theme filter for suggested-theme matching.
    func fetchCuratedPhotos(page: Int = 1, perPage: Int = 20, theme: String? = nil) async throws -> CuratedPhotosResponse {
        var items = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        if let theme = theme, !theme.isEmpty {
            items.append(URLQueryItem(name: "theme", value: theme))
        }
        struct Response: Decodable {
            let photos: [CuratedPhoto]
            let total: Int
            let page: Int
            let per_page: Int
            let total_pages: Int
        }
        let response: Response = try await makeRequest(
            endpoint: "images/curated",
            method: "GET",
            queryItems: items,
            includeUserId: true
        )
        return CuratedPhotosResponse(
            photos: response.photos,
            total: response.total,
            page: response.page,
            per_page: response.per_page,
            total_pages: response.total_pages
        )
    }

    /// Search Unsplash (privileged users only). Returns 403 for non-privileged.
    func searchUnsplashPhotos(query: String, page: Int = 1, perPage: Int = 10) async throws -> UnsplashSearchResponse {
        try await makeRequest(
            endpoint: "images/search",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ],
            includeUserId: true
        )
    }

    /// Trigger Unsplash download event when user selects a photo as theme. Requires X-User-Id.
    func triggerUnsplashDownload(unsplashPhotoId: String, downloadLocation: String) async throws {
        struct Request: Encodable {
            let unsplashPhotoId: String
            let download_location: String
        }
        struct Response: Decodable {
            let ok: Bool
        }
        let _: Response = try await makeRequest(
            endpoint: "images/trigger-download",
            method: "POST",
            body: Request(unsplashPhotoId: unsplashPhotoId, download_location: downloadLocation),
            includeUserId: true
        )
    }

    /// Submit photos that have been stable (unchanged) 7+ days for curation. Requires valid unlock key.
    func submitStablePhotosForCuration(_ photos: [FromStablePhotoItem]) async throws {
        struct Request: Encodable {
            let photos: [FromStablePhotoItem]
        }
        struct Response: Decodable {
            let added: Int
            let skipped: Int
        }
        let _: Response = try await makeRequest(
            endpoint: "images/curated/from-stable",
            method: "POST",
            body: Request(photos: photos),
            includeUserId: true
        )
    }

    /// URL for image proxy (backend caches Unsplash image by id).
    func imageProxyURL(photoId: String) -> URL? {
        guard !baseURL.isEmpty else { return nil }
        var components = URLComponents(string: "\(baseURL)/api/images/proxy")
        components?.queryItems = [URLQueryItem(name: "id", value: photoId)]
        return components?.url
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

// MARK: - Images / Unsplash

struct ImagesAccessResponse: Codable {
    let canSearch: Bool
    let unlimitedThemes: Bool
}

struct FromStablePhotoItem: Codable {
    let unsplash_photo_id: String
    let image_url: String
    let attribution_text: String
    let attribution_url: String
    let download_location: String
    let color: String?
}

struct CuratedPhoto: Codable {
    let id: String
    let unsplash_photo_id: String
    let image_url: String
    let attribution_text: String
    let attribution_url: String
    let download_location: String
    let approved_at: String
    let created_at: String
    let suggested_theme_name: String?
}

struct CuratedPhotosResponse {
    let photos: [CuratedPhoto]
    let total: Int
    let page: Int
    let per_page: Int
    let total_pages: Int
}

struct UnsplashPhotoSummary: Codable {
    let id: String
    let urls: UnsplashPhotoUrls?
    let links: UnsplashPhotoLinks?
    let user: UnsplashPhotoUser?
    let attributionText: String?
    let attributionUrl: String?
}

struct UnsplashPhotoUrls: Codable {
    let raw: String?
    let full: String?
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashPhotoLinks: Codable {
    let download_location: String
    let html: String?
}

struct UnsplashPhotoUser: Codable {
    let name: String?
    let username: String?
    let links: UnsplashUserLinks?
}

struct UnsplashUserLinks: Codable {
    let html: String?
}

struct UnsplashSearchResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [UnsplashPhotoSummary]
}
