import Foundation

public actor GoogleRefreshTokenProvider: TokenProvider {
    public enum Error: Swift.Error {
        case cannotLoadCredentialsData
        case cannotParseCredentials
    }

    public private(set) var token: Token?

    private let credentials: RefreshCredentials
    private let accessTokenURL = URL(string: "https://oauth2.googleapis.com/token")!

    private let apiClient: APIClient
    private let expirationLeeway: TimeInterval
    private let now: () -> Date

    // MARK: - Initializers

    public init(
        credentialsPath: String,
        expirationLeeway: TimeInterval = 60
    ) throws(Error) {
        try self.init(
            credentialsPath: credentialsPath,
            expirationLeeway: expirationLeeway,
            apiClient: URLSession(configuration: .default)
        )
    }

    internal init(
        credentialsPath: String,
        expirationLeeway: TimeInterval = 60,
        apiClient: APIClient,
        now: @escaping () -> Date = Date.init
    ) throws(Error) {
        self.apiClient = apiClient
        self.now = now
        self.expirationLeeway = expirationLeeway

        let credentialsURL = URL(fileURLWithPath: credentialsPath)
        let credentialsData: Data

        do {
            credentialsData = try Data(contentsOf: credentialsURL)
        } catch {
            throw .cannotLoadCredentialsData
        }

        do {
            credentials = try JSONDecoder().decode(RefreshCredentials.self, from: credentialsData)
        } catch {
            throw .cannotParseCredentials
        }
    }

    // MARK: - Public interface

    public func token() async throws(TokenProviderError) -> Token {
        let iat = now()

        if let token, token.expiresAt.timeIntervalSince(iat) > expirationLeeway {
            return token
        }

        let request = try createTokenRequest()
        let response = try await getAccessToken(request)
        let token = Token(
            accessToken: response.accessToken,
            tokenType: response.tokenType,
            issuedAt: iat,
            expiresIn: response.expiresIn
        )

        self.token = token

        return token
    }

    // MARK: - Private helpers

    private func createTokenRequest() throws(TokenProviderError) -> URLRequest {
        do {
            var request = URLRequest(url: accessTokenURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode([
                "client_id": credentials.clientID,
                "client_secret": credentials.clientSecret,
                "grant_type": "refresh_token",
                "refresh_token": credentials.refreshToken,
            ])
            return request
        } catch {
            throw .init(message: "Cannot create token request body: \(error.localizedDescription)")
        }
    }

    private func getAccessToken(
        _ request: URLRequest
    ) async throws(TokenProviderError) -> AccessTokenResponse {
        do {
            return try await apiClient.response(for: request)
        } catch {
            switch error {
            case .cannotGetResponse:
                throw .init(message: "Unable to get token response")
            case .cannotParseResponse:
                throw .init(message: "Unable to decode token response")
            }
        }
    }
}
