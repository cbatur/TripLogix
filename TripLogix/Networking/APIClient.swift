import Foundation

final class APIClient {
    static let shared = APIClient()

    private init() {}

    func request<T: Decodable>(_ endpoint: Endpoint, errorType: Decodable.Type? = nil) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        if let body = endpoint.body {
            request.httpBody = body
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.networkRequest(url: request.url, method: request.httpMethod ?? "Unknown", responseCode: nil, error: NetworkError.invalidResponse)
                throw NetworkError.invalidResponse
            }

            Logger.networkRequest(url: request.url, method: request.httpMethod ?? "Unknown", responseCode: httpResponse.statusCode, error: nil)


            if !(200...299).contains(httpResponse.statusCode) {
                if let errorType = errorType {
                    do {
                        let errorResponse = try JSONDecoder().decode(errorType, from: data)
                        throw NetworkError.serviceError(service: endpoint.service, error: errorResponse)
                    } catch {
                        throw NetworkError.invalidResponse
                    }
                } else {
                    throw NetworkError.invalidResponse
                }
            }

            return try JSONDecoder.apiDecoder.decode(T.self, from: data)

        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(decodingError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
