
import Foundation

struct FlightErrorResponse: Codable, Error {
    let error: String
    let success: Bool
}

final class FlightServices {
    
    /// Fetches available flights for the given date, origin, and destination.
    /// - Parameters:
    ///   - date: The departure date (format: YYYY-MM-DD).
    ///   - d: The departure airport/entity ID.
    ///   - a: The arrival airport/entity ID.
    /// - Returns: An array of `SSItinerary` objects.
    func searchFlights(date: String, d: String, a: String) async throws -> [SSItinerary] {
        let request = FlightRequests.FlightSearch(date: date, d: d, a: a) 
        let response: FlightResponse = try await APIClient.shared.request(request.endpoint, errorType: FlightErrorResponse.self)
        return response.data.itineraries
    }
    
    /// Searches for airports based on user input (e.g., airport name, city, or IATA code).
    /// - Parameter query: The search query (e.g., "Toronto", "LAX").
    /// - Returns: An array of `Airport` objects.
    func searchAirports(city: String) async throws -> AirportResponse {
        let request = FlightRequests.AirportSearch(city: city)
        let response: AirportResponse = try await APIClient.shared.request(request.endpoint, errorType: FlightErrorResponse.self)
        return response
    }
}
