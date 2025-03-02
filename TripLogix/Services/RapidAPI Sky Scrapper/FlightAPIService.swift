import Foundation

struct SSError: Codable, Error {
    let error: String
    let success: Bool
}

protocol FlightServiceProvider {
    func airportSearch(city: String) async throws -> AirportResponse
    func flightSearch(date: String, d: String, a: String) async throws -> [SSItinerary]
}

class FlightAPIService: FlightServiceProvider {
    
    private func apiCall<T: Codable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw SSError(error: "Server Error", success: false)
            }
            
            return try JSONDecoder().decode(T.self, from: data)
            
        } catch {
            throw SSError(error: "Parsing Error", success: false)
        }
    }
    
    func airportSearch(city: String) async throws -> AirportResponse {
        return try await apiCall(SkyScrapperRequests.CitySearch(city: city).request)
    }
    
    func flightSearch(date: String, d: String, a: String) async throws -> [SSItinerary] {
        let response: FlightResponse = try await apiCall(SkyScrapperRequests.FlightSearch(date: date, d: d, a: a).request)
        return response.data.itineraries
    }
}
