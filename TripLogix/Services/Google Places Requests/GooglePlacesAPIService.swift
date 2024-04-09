
import Foundation
import Combine

struct GPAPIError: Error, Decodable {
    let errorMessage: String
    let htmlAttributions: [String]
    let status: String

    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case htmlAttributions = "html_attributions"
        case status
    }
}

protocol GPServiceProvider {
    func searchGooglePlaceId(placeId: String) -> AnyPublisher<GooglePlace, GPAPIError>
}

class GooglePlacesAPIService: GPServiceProvider {

    private func apiCall<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, GPAPIError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in GPAPIError.init(errorMessage: "", htmlAttributions: [], status: "INVALID_REQUEST") }
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in GPAPIError.init(errorMessage: "", htmlAttributions: [], status: "REQUEST_DENIED")  }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func searchGooglePlaceId(placeId: String) -> AnyPublisher<GooglePlace, GPAPIError> {
        return self.apiCall(GooglePlacesRequests.SearchByPlaceId(placeId: placeId).request)
    }
}

