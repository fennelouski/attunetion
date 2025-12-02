# iOS Integration Guide

Quick reference for integrating the Daily Intentions backend API into the iOS app.

## Base URL

Replace `YOUR_VERCEL_URL` with your actual Vercel deployment URL:

```swift
let baseURL = "https://your-project.vercel.app"
```

## Authentication

If `API_SECRET_KEY` is configured, include it in requests:

```swift
request.setValue("your-api-key", forHTTPHeaderField: "X-API-Key")
// OR
request.setValue("Bearer your-api-key", forHTTPHeaderField: "Authorization")
```

For user identification (optional):
```swift
request.setValue(userId.uuidString, forHTTPHeaderField: "X-User-Id")
```

## Example: Generate Theme

```swift
struct ThemeResponse: Codable {
    let theme: Theme
}

struct Theme: Codable {
    let backgroundColor: String
    let textColor: String
    let accentColor: String
    let name: String
    let reasoning: String
}

func generateTheme(for intentionText: String) async throws -> Theme {
    guard let url = URL(string: "\(baseURL)/api/ai/generate-theme") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    request.setValue(userId.uuidString, forHTTPHeaderField: "X-User-Id")
    
    let body = ["intentionText": intentionText]
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    let themeResponse = try JSONDecoder().decode(ThemeResponse.self, from: data)
    return themeResponse.theme
}
```

## Example: Generate Quote

```swift
struct QuoteResponse: Codable {
    let quote: String
    let author: String
    let relevance: String
}

func generateQuote(for intentionText: String) async throws -> QuoteResponse {
    guard let url = URL(string: "\(baseURL)/api/ai/generate-quote") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    
    let body = ["intentionText": intentionText]
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(QuoteResponse.self, from: data)
}
```

## Example: Rephrase Intention

```swift
struct RephraseRequest: Codable {
    let intentionText: String
    let previousPhrases: [String]?
}

struct RephraseResponse: Codable {
    let rephrasedText: String
    let preservedMeaning: Bool
}

func rephraseIntention(
    _ text: String,
    avoiding previousPhrases: [String] = []
) async throws -> RephraseResponse {
    guard let url = URL(string: "\(baseURL)/api/ai/rephrase-intention") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    
    let body = RephraseRequest(
        intentionText: text,
        previousPhrases: previousPhrases.isEmpty ? nil : previousPhrases
    )
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(RephraseResponse.self, from: data)
}
```

## Example: Generate Monthly Intention

```swift
struct PreviousIntention: Codable {
    let text: String
    let month: String
}

struct MonthlyIntentionRequest: Codable {
    let previousIntentions: [PreviousIntention]
}

struct MonthlyIntentionResponse: Codable {
    let intention: String
    let reasoning: String
}

func generateMonthlyIntention(
    from previousIntentions: [PreviousIntention]
) async throws -> MonthlyIntentionResponse {
    guard let url = URL(string: "\(baseURL)/api/ai/generate-monthly-intention") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    
    let body = MonthlyIntentionRequest(previousIntentions: previousIntentions)
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(MonthlyIntentionResponse.self, from: data)
}
```

## Error Handling

```swift
struct APIError: Codable, Error {
    let error: ErrorDetail
}

struct ErrorDetail: Codable {
    let code: String
    let message: String
    let statusCode: Int
}

func handleAPIError(_ error: Error) {
    if let urlError = error as? URLError {
        // Handle network errors
        print("Network error: \(urlError.localizedDescription)")
    } else if let apiError = error as? APIError {
        // Handle API errors
        switch apiError.error.code {
        case "RATE_LIMIT_EXCEEDED":
            print("Rate limit exceeded: \(apiError.error.message)")
        case "UNAUTHORIZED":
            print("Authentication failed")
        case "VALIDATION_ERROR":
            print("Validation error: \(apiError.error.message)")
        default:
            print("API error: \(apiError.error.message)")
        }
    }
}
```

## Rate Limiting

Check rate limit headers in responses:

```swift
if let httpResponse = response as? HTTPURLResponse {
    let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining")
    let resetTime = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset")
    // Use these to show user remaining requests
}
```

## Caching Recommendations

1. **Theme Generation**: Cache themes for same intention text (24 hours)
2. **Quotes**: Cache quotes indefinitely (they don't change)
3. **Rephrasing**: Don't cache (always generate fresh)

## Testing

Use the health endpoint to verify connectivity:

```swift
func checkHealth() async throws {
    guard let url = URL(string: "\(baseURL)/api/health") else {
        throw URLError(.badURL)
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let health = try JSONDecoder().decode(HealthResponse.self, from: data)
    print("API Status: \(health.status)")
}
```

## Environment Configuration

Create a configuration file for different environments:

```swift
enum APIEnvironment {
    case development
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://localhost:3000"
        case .production:
            return "https://your-project.vercel.app"
        }
    }
    
    var apiKey: String {
        // Load from Info.plist or secure storage
        return Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
    }
}
```

