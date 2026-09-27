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
        print("PASS: all five AI endpoints deny before consent and after revocation; accepted theme decodes; revocation discards in-flight response; health works without consent. No external requests.")
    }
}
