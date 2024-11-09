import Foundation
import GoogleAuth
import Testing

struct ServiceAccountTokenProviderTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["GOOGLE_APPLICATION_CREDENTIALS"] != nil))
    func realToken() async throws {
        let path = try #require(ProcessInfo.processInfo.environment["GOOGLE_APPLICATION_CREDENTIALS"])
        let provider = try await ServiceAccountTokenProvider(
            serviceAccountPath: path,
            scopes: ["https://www.googleapis.com/auth/devstorage.read_only"]
        )

        await #expect(throws: Never.self) {
            try await provider.token()
        }
    }
}
