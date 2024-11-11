internal struct RefreshCredentials: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case refreshToken = "refresh_token"
        case tokenType = "type"
        case quotaProjectID = "quota_project_id"
    }

    let clientID: String
    let clientSecret: String
    let refreshToken: String
    let tokenType: String
    let quotaProjectID: String?
}
