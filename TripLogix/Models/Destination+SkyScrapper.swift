import Foundation
import SwiftData

// ------------- Sky Scrapper SwiftData ------------
@Model
class DSSLeg: Hashable {
    let id: String
    let origin: DSSAirportEntity
    let destination: DSSAirportEntity
    let durationInMinutes: Int
    let flightNumber: String?
    let stopCount: Int
    let departure: String
    let arrival: String
    let timeDeltaInDays: Int
    let carriers: DCarrier
    let segments: [DSSSegment]
    
    init(id: String, origin: DSSAirportEntity, destination: DSSAirportEntity, durationInMinutes: Int, flightNumber: String?, stopCount: Int, departure: String, arrival: String, timeDeltaInDays: Int, carriers: DCarrier, segments: [DSSSegment]) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.durationInMinutes = durationInMinutes
        self.flightNumber = flightNumber
        self.stopCount = stopCount
        self.departure = departure
        self.arrival = arrival
        self.timeDeltaInDays = timeDeltaInDays
        self.carriers = carriers
        self.segments = segments
    }
}
    
@Model
class DCarrier: Hashable {
    let marketing: [DSSMarketing]
    let operationType: String
    
    init(marketing: [DSSMarketing], operationType: String) {
        self.marketing = marketing
        self.operationType = operationType
    }
}

@Model
class DSSMarketing: Hashable {
    let logoUrl: String
    let name: String
    
    init(logoUrl: String, name: String) {
        self.logoUrl = logoUrl
        self.name = name
    }
}

@Model
class DSSAirportEntity: Hashable {
    let id: String
    let entityId: String
    let name: String
    let displayCode: String
    let city: String
    let country: String
    
    init(id: String, entityId: String, name: String, displayCode: String, city: String, country: String) {
        self.id = id
        self.entityId = entityId
        self.name = name
        self.displayCode = displayCode
        self.city = city
        self.country = country
    }
}

@Model
class DSSSegment: Hashable {
    let id: String
    let origin: DSSRoute
    let destination: DSSRoute
    let departure: String
    let arrival: String
    let durationInMinutes: Int
    let flightNumber: String
    let marketingCarrier: DSSCarrier
    
    init(id: String, origin: DSSRoute, destination: DSSRoute, departure: String, arrival: String, durationInMinutes: Int, flightNumber: String, marketingCarrier: DSSCarrier) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.departure = departure
        self.arrival = arrival
        self.durationInMinutes = durationInMinutes
        self.flightNumber = flightNumber
        self.marketingCarrier = marketingCarrier
    }
}

@Model
class DSSCarrier: Hashable {
    let name: String
    let alternateId: String
    
    init(name: String, alternateId: String) {
        self.name = name
        self.alternateId = alternateId
    }
}

@Model
class DSSRoute: Hashable {
    let flightPlaceId: String
    let name: String
    let type: String
    let country: String
    let parent: DSSRouteParent
    
    init(flightPlaceId: String, name: String, type: String, country: String, parent: DSSRouteParent) {
        self.flightPlaceId = flightPlaceId
        self.name = name
        self.type = type
        self.country = country
        self.parent = parent
    }
}

@Model
class DSSRouteParent: Hashable {
    let flightPlaceId: String
    let displayCode: String
    let name: String
    let type: String
    
    init(flightPlaceId: String, displayCode: String, name: String, type: String) {
        self.flightPlaceId = flightPlaceId
        self.displayCode = displayCode
        self.name = name
        self.type = type
    }
}
