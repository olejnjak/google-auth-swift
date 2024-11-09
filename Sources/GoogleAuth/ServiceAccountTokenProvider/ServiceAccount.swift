import Foundation

public struct ServiceAccount: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case type
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case tokenUri = "token_uri"
    }

    public let type: String
    public let privateKey: String
    public let clientEmail: String
    public let tokenUri: URL

    public init(
        type: String,
        privateKey: String,
        clientEmail: String,
        tokenUri: URL
    ) {
        self.type = type
        self.privateKey = privateKey
        self.clientEmail = clientEmail
        self.tokenUri = tokenUri
    }
}
