import Foundation

public protocol TokenProvider {
    func token() async throws(TokenProviderError) -> Token
}

public struct Token: Sendable, Codable {
    public let accessToken: String
    public let tokenType: String
    public let issuedAt: Date
    public let expiresIn: TimeInterval
    public let refreshToken: String
    public let refreshTokenIssuedAt: Date
    public let refreshTokenExpiresIn: TimeInterval
    public let scope: String

    public var expiresAt: Date {
        issuedAt.addingTimeInterval(expiresIn)
    }
}

public struct TokenProviderError: Error, Sendable {
    public let message: String
}
