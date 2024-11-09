import Foundation

public struct ServiceAccount: Decodable, Sendable {
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

package extension JSONDecoder {
    static var serviceAccount: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
