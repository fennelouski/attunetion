import Foundation
import SwiftData

final class RequestProbe: URLProtocol, @unchecked Sendable {
    private static let lock = NSLock()
    private static var requests: [URLRequest] = []
    static var beforeResponse: (@MainActor () -> Void)?
    static var captured: [URLRequest] {
        lock.lock()
        defer { lock.unlock() }
        return requests
    }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Self.lock.lock()
        Self.requests.append(request)
        Self.lock.unlock()
        Task { @MainActor in
            Self.beforeResponse?()
            sendResponse()
        }
    }
    private func sendResponse() {
        let json = request.url!.path == "/api/health"
            ? #"{"status":"ok","timestamp":"2026-09-27","version":"1.0"}"#
            : ##"{"theme":{"backgroundColor":"#FFFFFF","textColor":"#000000","accentColor":"#0000FF","name":"Focus","reasoning":"Readable contrast"}}"##
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(json.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@main
struct ConsentChecks {
    @MainActor static func main() async throws {
        let container = try ModelContainer(for: UserProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        let context = container.mainContext
        let profile = UserProfileRepository(modelContext: context).getOrCreateProfile()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [RequestProbe.self]
        let client = APIClient(session: URLSession(configuration: configuration))
        let requests: [() async throws -> Void] = [
            { _ = try await client.generateTheme(intentionText: "Synthetic focus", modelContext: context) },
            { _ = try await client.generateQuote(intentionText: "Synthetic focus", modelContext: context) },
            { _ = try await client.rephraseIntention(intentionText: "Synthetic focus", modelContext: context) },
            { _ = try await client.generateMonthlyIntention(previousIntentions: [], modelContext: context) },
            { _ = try await client.generateWeeklyIntentions(userInfo: "Synthetic profile", weekStartDate: Date(), modelContext: context) }
        ]
        for request in requests {
            do {
                try await request()
                fatalError("An AI request bypassed consent")
            } catch ConsentError.termsNotAccepted {}
        }
        precondition(RequestProbe.captured.isEmpty, "Denied requests reached the network")
        let healthy = try await client.checkHealth()
        precondition(healthy && RequestProbe.captured.count == 1)
        try ConsentManager.shared.acceptTerms(modelContext: context)
        let theme = try await client.generateTheme(intentionText: "Synthetic focus", modelContext: context)
        precondition(theme.name == "Focus" && RequestProbe.captured.count == 2)
        precondition(RequestProbe.captured.last?.url?.path == "/api/ai/generate-theme")
        profile.autoGenerateEnabled = true
        RequestProbe.beforeResponse = {
            try! ConsentManager.shared.revokeConsent(modelContext: context)
        }
        do {
            _ = try await client.generateTheme(intentionText: "Synthetic in-flight response", modelContext: context)
            fatalError("An in-flight response survived consent revocation")
        } catch ConsentError.termsNotAccepted {}
        RequestProbe.beforeResponse = nil
        precondition(!profile.hasAcceptedTerms && !profile.autoGenerateEnabled && profile.termsAcceptedDate == nil)
        for request in requests {
            do {
                try await request()
                fatalError("Revoked consent allowed an AI request")
            } catch ConsentError.termsNotAccepted {}
        }
        precondition(RequestProbe.captured.count == 3, "Revoked requests reached the network")
        // Execute the exact history projection extracted from AutoIntentionService.
        // New periods appear among the newest records, before older API-compatible ones.
        let scopes: [IntentionScope] = [.season, .year, .day, .week, .month, .season,
            .day, .year, .week, .month, .day, .week, .month, .day, .week, .month, .day]
        let allIntentions = scopes.enumerated().map { index, scope in
            Intention(text: "Synthetic history \(index)", scope: scope,
                      date: Date(timeIntervalSince1970: 1_800_000_000 - Double(index * 86_400)))
        }
        let expected = Array(allIntentions.filter {
            $0.scope == .day || $0.scope == .week || $0.scope == .month
        }.prefix(10))
        let history = weeklyHistoryForConsentCheck(from: allIntentions)
        let encoded = try JSONEncoder().encode(history)
        let rows = try JSONSerialization.jsonObject(with: encoded) as! [[String: String]]
        guard rows.count == 10,
              rows.map({ $0["text"] }) == expected.map({ Optional($0.text) }),
              rows.map({ $0["scope"] }) == expected.map({ Optional($0.scope.rawValue) }),
              rows.map({ $0["date"] }) == expected.map({ Optional(ISO8601DateFormatter().string(from: $0.date)) }),
              rows.allSatisfy({ ["day", "week", "month"].contains($0["scope"] ?? "") }) else {
            FileHandle.standardError.write(Data("FAIL: Weekly history must contain the ten newest API-compatible records in order.\n".utf8))
            exit(1)
        }
        precondition(weeklyHistoryForConsentCheck(from: []).isEmpty)
        precondition(weeklyHistoryForConsentCheck(from: Array(allIntentions.prefix(2))).isEmpty)
        let shortHistory = weeklyHistoryForConsentCheck(from: Array(allIntentions.prefix(5)))
        precondition(shortHistory.map(\.text) == Array(expected.prefix(3)).map(\.text))
        print("PASS: all five AI endpoints deny before consent and after revocation; accepted theme decodes; revocation discards in-flight response; health works without consent. No external requests.")
        print("PASS: weekly history filters season/year before its ten-record limit; encoded text, scope, date and order match; empty, unsupported-only and short histories stay bounded.")
    }
}
