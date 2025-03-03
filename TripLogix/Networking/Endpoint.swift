
import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

struct Endpoint {
    let service: APIService 
    let baseURL: String
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem]? = nil
    var headers: [String: String] = ["Content-Type": "application/json"]
    var body: Data? = nil

    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path.append(path)
        components?.queryItems = queryItems
        return components?.url
    }
}
