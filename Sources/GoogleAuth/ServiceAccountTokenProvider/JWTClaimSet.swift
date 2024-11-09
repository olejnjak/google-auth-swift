import JWTKit

internal struct JWTClaimSet: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case audience = "aud"
        case scope = "scope"
        case issuedAt = "iat"
        case expiration = "exp"
    }

    let issuer: String
    let audience: String
    let scope: String
    let issuedAt: Int
    let expiration: Int

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try ExpirationClaim(value: .init(timeIntervalSince1970: .init(expiration)))
            .verifyNotExpired()
    }
}
