import Foundation
@testable import GoogleAuth

final class MockAPIClient: APIClient, @unchecked Sendable {
    var dataBody: (URLRequest) async throws(APIClientError) -> Data = { _ in
        .init()
    }

    func data(
        for request: URLRequest
    ) async throws(APIClientError) -> Data {
        try await dataBody(request)
    }
}
