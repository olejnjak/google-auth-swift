import Foundation
import GoogleAuth
import Testing

struct ServiceAccountTests {
    @Test
    func decoding() async throws {
        let json = """
        {
        "type": "service_account",
        "project_id": "project_id",
        "private_key_id": "privateKeyId",
        "private_key": "privateKey",
        "client_email": "email@example.com",
        "client_id": "clientId",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/swiftci-match%40ackee-production.iam.gserviceaccount.com"
        }
        """

        #expect(throws: Never.self) {
            try JSONDecoder.serviceAccount.decode(
                ServiceAccount.self,
                from: .init(json.utf8)
            )
        }
    }
}
