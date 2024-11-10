import Foundation

public struct DefaultCredentialsTokenProvider: TokenProvider {
    public let tokenProvider: TokenProvider

    // MARK: - Initializers

    public init?(scopes: [String]) async {
        do {
            if let googleAppCredentials = ProcessInfo.processInfo.googleApplicationCredentials {
                tokenProvider = try await ServiceAccountTokenProvider(
                    serviceAccountPath: googleAppCredentials,
                    scopes: scopes
                )
            } else if FileManager.default.fileExists(atPath: URL.applicationDefaultCredentialsJSON.path()) {
                tokenProvider = try GoogleRefreshTokenProvider(
                    credentialsPath: URL.applicationDefaultCredentialsJSON.path()
                )
            } else {
                // TODO: Should use GoogleCloudMetadata provider in future
                return nil
            }
        } catch {
            return nil
        }
    }

    // MARK: - Public interface

    public func token() async throws(TokenProviderError) -> Token {
        try await tokenProvider.token()
    }
}
