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
    
    /// Date of token expiration
    public var expiresAt: Date {
        issuedAt.addingTimeInterval(expiresIn)
    }
}

/// Error thrown when token provider encouters any issues
public struct TokenProviderError: Error, Sendable {
    /// Error message
    public let message: String
}
