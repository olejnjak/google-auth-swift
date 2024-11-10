import Foundation

internal enum APIClientError: Error {
    case cannotGetResponse, cannotParseResponse
}

internal protocol APIClient: Sendable {
    func data(for request: URLRequest) async throws(APIClientError) -> Data
}

extension APIClient {
    func response<Response: Decodable>(
        for request: URLRequest,
        using decoder: JSONDecoder = .init()
    ) async throws(APIClientError) -> Response {
        let data = try await data(for: request)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw .cannotParseResponse
        }
    }
}

extension URLSession: APIClient {
    func data(for request: URLRequest) async throws(APIClientError) -> Data {
        do {
            return try await data(for: request).0
        } catch {
            throw .cannotGetResponse
        }
    }
}
