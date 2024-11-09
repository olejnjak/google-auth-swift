import JWTKit

internal struct JWTClaimSet: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case audience = "aud"
        case scope = "scope"
        case issuedAt = "iat"
        case expiration = "exp"
    }

    let issuer: IssuerClaim
    let audience: AudienceClaim
    let scope: String
    let issuedAt: IssuedAtClaim
    let expiration: ExpirationClaim

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}
