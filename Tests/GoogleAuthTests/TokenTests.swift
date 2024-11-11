import Foundation
@testable import GoogleAuth
import Testing

struct TokenTests {
    @Test(arguments: [
        "quotaProjectID",
        nil
    ])
    func requestHeaders(quotaProjectID: String?) throws {
        let url = try #require(URL(string: "https://github.com"))
        let token = Token(
            accessToken: "accessToken",
            tokenType: "tokenType",
            issuedAt: .init(),
            expiresIn: 3600,
            quotaProjectID: quotaProjectID
        )
        var request = URLRequest(url: url)
        token.add(to: &request)

        var expectedRequest = URLRequest(url: url)
        expectedRequest.setValue("tokenType accessToken", forHTTPHeaderField: "Authorization")

        if let quotaProjectID {
            expectedRequest.setValue(quotaProjectID, forHTTPHeaderField: "x-goog-user-project")
        }

        #expect(expectedRequest == request)
    }
}
