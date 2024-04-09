
import Foundation
import Combine

enum APIError: Error {
    case internalError
    case serverError
    case parsingError
}

protocol ServiceProvider {
    func searchLocation(keyword: String) -> AnyPublisher<[Location], APIError>
    func flightImageUpload(imageName: String, imageString: String) -> AnyPublisher<TLImageUrl, APIError>
}

class TLAPIService: ServiceProvider {

    private func apiCall<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, APIError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in APIError.serverError }
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in APIError.parsingError }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func searchLocation(keyword: String) -> AnyPublisher<[Location], APIError> {
        return self.apiCall(TLRequests.SearchGooglePlaces(keyword: keyword).request)
    }
    
    func flightImageUpload(imageName: String, imageString: String) -> AnyPublisher<TLImageUrl, APIError> {
        return self.apiCall(TLRequests.FlightImageUpload(imageString: imageString, imageName: imageName).request)
    }
}

