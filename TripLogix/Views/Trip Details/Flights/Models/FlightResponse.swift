import Foundation

struct FlightResponse: Codable, Hashable {
    let data: SSFlight
}

struct SSFlight: Codable, Hashable {
    let itineraries: [SSItinerary]
}

struct SSItinerary: Codable, Hashable {
    let id: String
    let legs: [Leg]
    let price: Price
    
    struct Price: Codable, Hashable {
        let raw: Double
        let formatted: String
    }
}
