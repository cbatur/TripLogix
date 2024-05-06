
import Foundation
import Combine

struct SSError: Codable, Error {
    let error: String
    let success: Bool
}

protocol SSServiceProvider {
    func airportSearch(city: String) -> AnyPublisher<SSAirportResponse, SSError>
    func flightSearch(date: String, d: String, a: String) -> AnyPublisher<SSFlightResponse, SSError>

}

class SkyScrapperAPIService: SSServiceProvider {

    private func apiCall<T: Codable>(_ request: URLRequest) -> AnyPublisher<T, SSError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in SSError(error: "Server Error", success: false) }
            .map { $0.data }
            .print()
            .decode(type: T.self, decoder: JSONDecoder())
            .print()
            .mapError { _ in SSError(error: "Parsing Error", success: false) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func airportSearch(city: String) -> AnyPublisher<SSAirportResponse, SSError> {
        return self.apiCall(SkyScrapperRequests.CitySearch(city: city).request)
    }
    
    func flightSearch(date: String, d: String, a: String) -> AnyPublisher<SSFlightResponse, SSError> {
        return self.apiCall(SkyScrapperRequests.FlightSearch(date: date, d: d, a:a).request)
    }

}

