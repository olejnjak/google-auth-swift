import Foundation

public protocol TokenProvider {
    func token() async throws(TokenProviderError) -> Token
}

public struct Token: Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: TimeInterval
    public let scope: String
}

public struct TokenProviderError: Error, Sendable {

}
