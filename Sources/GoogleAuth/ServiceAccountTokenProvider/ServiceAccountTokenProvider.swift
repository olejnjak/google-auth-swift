import Foundation
import JWTKit

public actor ServiceAccountTokenProvider: TokenProvider {
    public enum Error: Swift.Error {
        case invalidPrivateKey
    }

    public private(set) var token: Token?

    private let now: () -> Date
    private let expirationLeeway: TimeInterval
    private let networkRequest: (URLRequest) async throws -> (Data, URLResponse)

    private let serviceAccount: ServiceAccount
    private let scopes: [String]
    private let keys = JWTKeyCollection()

    // MARK: - Initializers

    public init(
        serviceAccount: ServiceAccount,
        scopes: [String],
        expirationLeeway: TimeInterval = 60,
        now: @escaping () -> Date = { .init() },
        networkRequest: @escaping (URLRequest) async throws -> (Data, URLResponse) = {
            try await URLSession(configuration: .default).data(for: $0)
        }
    ) async throws(Error) {
        assert(expirationLeeway >= 0, "expirationLeeway must be non-negative")

        self.expirationLeeway = expirationLeeway
        self.now = now
        self.networkRequest = networkRequest

        self.serviceAccount = serviceAccount
        self.scopes = scopes

        do {
            let rsaKey = try Insecure.RSA.PrivateKey(pem: serviceAccount.privateKey)
            await keys.add(rsa: rsaKey, digestAlgorithm: .sha256)
        } catch {
            throw .invalidPrivateKey
        }
    }

    // MARK: - Public interface

    public func token() async throws(TokenProviderError) -> Token {
        let iat = now()

        if let token, iat.timeIntervalSince(token.expiresAt) > expirationLeeway {
            return token
        }

        let jwt = try await createJWT(
            iat: iat,
            exp: iat.addingTimeInterval(3_600)
        )

        let request = try createTokenRequest(jwt: jwt)
        let (responseData, _) = try await sendTokenRequest(request)

        return try decodeTokenResponse(responseData)
    }

    // MARK: - Private helpers

    private func createJWT(
        iat: Date,
        exp: Date
    ) async throws(TokenProviderError) -> String {
        let jwtClaimSet = JWTClaimSet(
            issuer: serviceAccount.clientEmail,
            audience: serviceAccount.tokenUri.absoluteString,
            scope: scopes.joined(separator: " "),
            issuedAt: .init(iat.timeIntervalSince1970),
            expiration: .init(exp.timeIntervalSince1970)
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

        var request = URLRequest(url: serviceAccount.tokenUri)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func sendTokenRequest(
        _ request: URLRequest
    ) async throws(TokenProviderError) -> (Data, URLResponse) {
        do {
            return try await networkRequest(request)
        } catch {
            throw .init(message: "Unable to get token response: \(error.localizedDescription)")
        }
    }

    private func decodeTokenResponse(
        _ response: Data
    ) throws(TokenProviderError) -> Token {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970

        do {
            return try decoder.decode(Token.self, from: response)
        } catch {
            throw .init(message: "Unable to decode token response: \(error.localizedDescription)")
        }
    }
}
