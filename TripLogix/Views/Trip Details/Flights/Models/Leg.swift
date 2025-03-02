import Foundation

struct Leg: Codable, Hashable {
    let id: String
    let origin: AirportEntity
    let destination: AirportEntity
    let durationInMinutes: Int
    let flightNumber: String?
    let stopCount: Int
    let departure: String
    let arrival: String
    let timeDeltaInDays: Int
    let carriers: Carrier
    let segments: [Segment]
    
    struct Carrier: Codable, Hashable {
        let marketing: [Marketing]
        let operationType: String
        
    }
    
    struct Segment: Codable, Hashable {
        let id: String
        let origin: Route
        let destination: Route
        let departure: String
        let arrival: String
        let durationInMinutes: Int
        let flightNumber: String
        let marketingCarrier: Carrier
        
        struct Carrier: Codable, Hashable {
            let name: String
            let alternateId: String
        }

        struct Route: Codable, Hashable {
            let flightPlaceId: String
            let name: String
            let type: String
            let country: String
            let parent: RouteParent
        }
        
        struct RouteParent: Codable, Hashable {
            let flightPlaceId: String
            let displayCode: String
            let name: String
            let type: String
        }
    }
    
    struct Marketing: Codable, Hashable {
        let id: Int
        let logoUrl: String
        let name: String
    }
    
    struct AirportEntity: Codable, Hashable {
        let id: String
        let entityId: String
        let name: String
        let displayCode: String
        let city: String
        let country: String
    }
}
