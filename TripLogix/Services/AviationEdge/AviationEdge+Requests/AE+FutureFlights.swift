
import Foundation

struct AEFutureFlight: Codable, Hashable, Identifiable, Equatable {
    let id = UUID()
    var weekday: String
    var departure: AirportDetail
    var arrival: AirportDetail
    var aircraft: Aircraft
    var airline: Airline
    var flight: Flight
    
    struct Flight: Codable, Hashable {
        var number: String
        var iataNumber: String
        var icaoNumber: String
    }

    struct Airline: Codable, Hashable {
        var name: String
        var iataCode: String
        var icaoCode: String
    }

    struct Aircraft: Codable, Hashable {
        var modelCode: String
        var modelText: String
    }

    struct AirportDetail: Codable, Hashable {
        var iataCode: String
        var icaoCode: String
        var terminal: String
        var gate: String
        var scheduledTime: String
    }
}

struct AEFutureFlightParams: Decodable, Hashable {
    let iataCode: String
    let type: String
    let date: String
    let destinationIataCode: String?
}

extension AERequests {
    struct FutureFlights {
        var futureFlightParams: AEFutureFlightParams
        
        var request: URLRequest {
            var components = URLComponents(string: "https://aviation-edge.com/v2/public/flightsFuture")
            
            guard let apiKey = decryptAPIKey(.avionEdge) else { preconditionFailure("Bad API Key") }
            
            var queryItems: [URLQueryItem] = [URLQueryItem(name: "key", value: apiKey)]
            queryItems.append(URLQueryItem(name: "iataCode", value: self.futureFlightParams.iataCode))
            queryItems.append(URLQueryItem(name: "type", value: self.futureFlightParams.type))
            queryItems.append(URLQueryItem(name: "date", value: self.futureFlightParams.date))
            
            components?.queryItems = queryItems
            
            guard let url = components?.url else { preconditionFailure("Bad URL") }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "accept")

            return request
        }
    }
}
