import Foundation

public struct ServiceAccount: Decodable, Sendable {
    public let type: String
    public let projectId: String
    public let privateKeyId: String
    public let privateKey: String
    public let clientEmail: String
    public let clientId: String
    public let authUri: URL
    public let tokenUri: URL
    public let authProviderX509CertUrl: URL
    public let clientX509CertUrl: URL

    public init(
        type: String,
        projectId: String,
        privateKeyId: String,
        privateKey: String,
        clientEmail: String,
        clientId: String,
        authUri: URL,
        tokenUri: URL,
        authProviderX509CertUrl: URL,
        clientX509CertUrl: URL
    ) {
        self.type = type
        self.projectId = projectId
        self.privateKeyId = privateKeyId
        self.privateKey = privateKey
        self.clientEmail = clientEmail
        self.clientId = clientId
        self.authUri = authUri
        self.tokenUri = tokenUri
        self.authProviderX509CertUrl = authProviderX509CertUrl
        self.clientX509CertUrl = clientX509CertUrl
    }
}

package extension JSONDecoder {
    static var serviceAccount: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
