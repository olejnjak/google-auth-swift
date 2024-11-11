import Foundation

/// Interface for fetch access tokens for Google APIs
public protocol TokenProvider {
    /// Fetch token for Google APIs
    func token() async throws(TokenProviderError) -> Token
}

/// Token retrieved for Google API access
public struct Token: Sendable, Codable, Hashable {
    /// Access token
    public let accessToken: String
    /// Token type
    public let tokenType: String
    /// Date of token creation
    public let issuedAt: Date
    /// Token expiration interval
    public let expiresIn: TimeInterval
    /// If this field is not-nil you are using [Application Default Credentials]() and you should include `x-goog-user-project`
    ///
    /// See more about setting billing at [Set billing project](https://cloud.google.com/docs/authentication/rest#set-billing-project)
    public let quotaProjectID: String?

    /// Date of token expiration
    public var expiresAt: Date {
        issuedAt.addingTimeInterval(expiresIn)
    }
    
    /// Sets appropriate headers to given request, basically `Authorization` and probably `x-goog-user-project`
    /// - Parameter request: URL request to be modified
    ///
    /// If headers with same name were present, they will be overwritten.
    public func add(to request: inout URLRequest) {
        request.setValue(tokenType + " " + accessToken, forHTTPHeaderField: "Authorization")

        if let quotaProjectID {
            request.setValue(quotaProjectID, forHTTPHeaderField: "x-goog-user-project")
        }
    }
}

/// Error thrown when token provider encouters any issues
public struct TokenProviderError: Error, Sendable {
    /// Error message
    public let message: String
}
