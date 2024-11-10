import Foundation

/// Provider implementing [Application default credentials](https://cloud.google.com/docs/authentication/application-default-credentials).
///
/// At least for now it implements only `GOOGLE_APPLICATION_CREDENTIALS` environment variable with a path to service account
/// and refresh token flow using `gcloud auth application-default login`. That is point 1 and 2 from [ADC search order](https://cloud.google.com/docs/authentication/application-default-credentials#order).
/// Fetching credentials from Google Metadata server (point 3) is not implemented yet.
public struct DefaultCredentialsTokenProvider: TokenProvider {
    private let tokenProvider: TokenProvider

    // MARK: - Initializers
    
    /// Create new provider with required scopes
    /// - Parameter scopes: Required scopes
    ///
    /// This provider creates appropriate provider based on your environment, if it fails, the initializer will return `nil`
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
