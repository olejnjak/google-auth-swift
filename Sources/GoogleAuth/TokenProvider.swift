import Foundation

public protocol TokenProvider {
    func token() async throws(TokenProviderError) -> Token
}

public struct Token: Sendable, Codable, Hashable {
    public let accessToken: String
    public let tokenType: String
    public let issuedAt: Date
    public let expiresIn: TimeInterval

    public var expiresAt: Date {
        issuedAt.addingTimeInterval(expiresIn)
    }
}

public struct TokenProviderError: Error, Sendable {
    public let message: String
}
