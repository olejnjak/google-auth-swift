import Foundation
@testable import GoogleAuth
import Testing

struct GoogleRefreshTokenProviderTests {
    @Test(.enabled(if: FileManager.default.fileExists(atPath: URL.applicationDefaultCredentialsJSON.path())))
    func realToken() async throws {
        let provider = try GoogleRefreshTokenProvider(
            credentialsPath: URL.applicationDefaultCredentialsJSON.path()
        )

        await #expect(throws: Never.self) {
            let token = try await provider.token()
            print(token)
        }
    }
}
