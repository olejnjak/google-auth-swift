import Foundation
@testable import GoogleAuth
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

    @Test
    func invalidServiceAccountPath() async throws {
        await #expect(throws: ServiceAccountTokenProvider.Error.cannotLoadServiceAccount) {
            try await ServiceAccountTokenProvider(
                serviceAccountPath: "path",
                scopes: ["https://www.googleapis.com/auth/devstorage.read_only"]
            )
        }
    }

    @Test
    func tokenIsCached() async throws {
        let mockAPI = MockAPIClient()
        mockAPI.dataBody = { _ in .testAccessTokenResponse(token: "token1") }

        let provider = try await ServiceAccountTokenProvider(
            serviceAccount: .test(),
            scopes: [],
            now: { .init() },
            apiClient: mockAPI
        )

        await #expect(provider.token == nil)

        let token1 = try await provider.token()

        #expect(await provider.token == token1)

        mockAPI.dataBody = { _ in .testAccessTokenResponse(token: "token2") }

        let token2 = try await provider.token()

        #expect(token1 == token2)
    }
}
