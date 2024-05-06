import Foundation

extension SkyScrapperRequests {
    struct FlightSearch {
        
        var date: String
        var d: String
        var a: String
        
        var request: URLRequest {
            var components = URLComponents(string: "https://\(Configuration.SkyScrapper.apiHost)/flights/search-one-way")
            
            guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }
            
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "fromEntityId", value: self.d),
                URLQueryItem(name: "toEntityId", value: self.a),
                URLQueryItem(name: "departDate", value: self.date),
            ]
            
            components?.queryItems = queryItems
            
            guard let url = components?.url else { preconditionFailure("Bad URL") }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(Configuration.SkyScrapper.apiHost, forHTTPHeaderField: "X-RapidAPI-Host")
            request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

            return request
        }
    }
}

struct SSFlightResponse: Codable, Hashable {
    let data: SSFlight
}

struct SSFlight: Codable, Hashable {
    let itineraries: [SSItinerary]
}

struct SSItinerary: Codable, Hashable {
    let id: String
    let legs: [SSLeg]
    let price: SSPrice
    
    struct SSPrice: Codable, Hashable {
        let raw: Double
        let formatted: String
    }
}

struct SSLeg: Codable, Hashable {
    let id: String
    let origin: SSAirportEntity
    let destination: SSAirportEntity
    let durationInMinutes: Int
    let flightNumber: String?
    let stopCount: Int
    let departure: String
    let arrival: String
    let timeDeltaInDays: Int
    let carriers: SSCarrier
    let segments: [SSSegment]
    
    struct SSCarrier: Codable, Hashable {
        let marketing: [SSMarketing]
        let operationType: String
        
    }
    
    struct SSSegment: Codable, Hashable {
        let id: String
        let origin: SSRoute
        let destination: SSRoute
        let departure: String
        let arrival: String
        let durationInMinutes: Int
        let flightNumber: String
        let marketingCarrier: SSCarrier
        
        struct SSCarrier: Codable, Hashable {
            let name: String
            let alternateId: String
//            "name": "British Airways",
//            "alternateId": "BA",
        }

        struct SSRoute: Codable, Hashable {
            let flightPlaceId: String
            let name: String
            let type: String
            let country: String
            let parent: SSRouteParent
        }
        
        struct SSRouteParent: Codable, Hashable {
            let flightPlaceId: String
            let displayCode: String
            let name: String
            let type: String
        }
    }
    
    struct SSMarketing: Codable, Hashable {
        let id: Int
        let logoUrl: String
        let name: String
        
//        "id":-31679,
//       "logoUrl":"https://logos.skyscnr.com/images/airlines/favicon/WS.png",
//       "name":"WestJet"
    }
    
    struct SSAirportEntity: Codable, Hashable {
        let id: String
        let entityId: String
        let name: String
        let displayCode: String
        let city: String
        let country: String
        
//        "origin":{
//             "id":"YYZ",
//             "entityId":"95673353",
//             "name":"Toronto Pearson International",
//             "displayCode":"YYZ",
//             "city":"Toronto",
//             "country":"Canada",
//             "isHighlighted":false
//          }
    }
}
