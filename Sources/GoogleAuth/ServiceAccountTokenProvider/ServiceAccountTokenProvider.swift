import Foundation
import JWTKit

public actor ServiceAccountTokenProvider: TokenProvider {
    public enum Error: Swift.Error {
        case invalidPrivateKey
        case cannotLoadServiceAccount
    }

    private struct AccessTokenResponse: Decodable {
        let accessToken: String
        let expiresIn: TimeInterval
        let tokenType: String
    }

    public private(set) var token: Token?

    private let now: () -> Date
    private let expirationLeeway: TimeInterval
    private let apiClient: APIClient

    private let serviceAccount: ServiceAccount
    private let scopes: [String]
    private let keys = JWTKeyCollection()

    // MARK: - Initializers

    public init(
        serviceAccountPath: String,
        scopes: [String],
        expirationLeeway: TimeInterval = 60
    ) async throws(Error) {
        try await self.init(
            serviceAccountPath: serviceAccountPath,
            scopes: scopes,
            expirationLeeway: expirationLeeway,
            now: { .init() }
        )
    }

    internal init(
        serviceAccount: ServiceAccount,
        scopes: [String],
        expirationLeeway: TimeInterval = 60,
        now: @escaping () -> Date,
        apiClient: APIClient = URLSession(configuration: .default)
    ) async throws(Error) {
        assert(expirationLeeway >= 0, "expirationLeeway must be non-negative")

        self.expirationLeeway = expirationLeeway
        self.now = now
        self.apiClient = apiClient

        self.serviceAccount = serviceAccount
        self.scopes = scopes

        do {
            let rsaKey = try Insecure.RSA.PrivateKey(pem: serviceAccount.privateKey)
            await keys.add(rsa: rsaKey, digestAlgorithm: .sha256)
        } catch {
            throw .invalidPrivateKey
        }
    }

    internal init(
        serviceAccountPath: String,
        scopes: [String],
        expirationLeeway: TimeInterval = 60,
        now: @escaping () -> Date,
        apiClient: APIClient = URLSession(configuration: .default)
    ) async throws(Error) {
        let sa: ServiceAccount

        do {
            sa = try JSONDecoder().decode(
                ServiceAccount.self,
                from: .init(contentsOf: .init(filePath: serviceAccountPath))
            )
        } catch {
            throw .cannotLoadServiceAccount
        }

        try await self.init(
            serviceAccount: sa,
            scopes: scopes,
            expirationLeeway: expirationLeeway,
            now: now,
            apiClient: apiClient
        )
    }

    // MARK: - Public interface

    public func token() async throws(TokenProviderError) -> Token {
        let iat = now()

        if let token, token.expiresAt.timeIntervalSince(iat) > expirationLeeway {
            return token
        }

        let jwt = try await createJWT(
            iat: iat,
            exp: iat.addingTimeInterval(3_600)
        )

        let request = try createTokenRequest(jwt: jwt)
        let response = try await getToken(request)

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

    private func createJWT(
        iat: Date,
        exp: Date
    ) async throws(TokenProviderError) -> String {
        let jwtClaimSet = JWTClaimSet(
            issuer: .init(value: serviceAccount.clientEmail),
            audience: .init(value: [serviceAccount.tokenURI.absoluteString]),
            scope: scopes.joined(separator: " "),
            issuedAt: .init(value: iat),
            expiration: .init(value: exp)
        )

        do {
            return try await keys.sign(
                jwtClaimSet,
                header: ["alg": "RS256", "typ": "JWT"]
            )
        } catch {
            throw .init(message: "Unable to sign JWT token: \(error.localizedDescription)")
        }
    }

    private func createTokenRequest(
        jwt: String
    ) throws(TokenProviderError) -> URLRequest {
        let encoder = JSONEncoder()
        let requestBody: Data

        do {
            requestBody = try encoder.encode([
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": jwt
            ])
        } catch {
            throw .init(message: "Cannot encode token request body: \(error.localizedDescription)")
        }

        var request = URLRequest(url: serviceAccount.tokenURI)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func getToken(
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
