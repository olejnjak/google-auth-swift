import Foundation

internal struct ServiceAccount: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case type
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case tokenURI = "token_uri"
    }

    let type: String
    let privateKey: String
    let clientEmail: String
    let tokenURI: URL
}
