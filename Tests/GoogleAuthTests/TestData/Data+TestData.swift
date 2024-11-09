import Foundation

extension Data {
    static func testAccessTokenResponse(
        token: String = "token",
        expiresIn: TimeInterval = 3600,
        tokenType: String = "Bearer"
    ) -> Data {
        .init("""
        {
            "access_token": "\(token)",
            "expires_in": \(Int(expiresIn)),
            "token_type": "\(tokenType)"
        }
        """.utf8)
    }
}
