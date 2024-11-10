import Foundation

internal struct AccessTokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }

    let accessToken: String
    let expiresIn: TimeInterval
    let tokenType: String
}
