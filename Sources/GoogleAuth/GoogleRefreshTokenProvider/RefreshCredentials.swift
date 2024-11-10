internal struct RefreshCredentials: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case refreshToken = "refresh_token"
        case tokenType = "type"
    }

    let clientID: String
    let clientSecret: String
    let refreshToken: String
    let tokenType: String
}
