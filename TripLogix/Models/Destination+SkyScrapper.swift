import Foundation
import SwiftData

// ------------- Sky Scrapper SwiftData ------------
@Model
class DSSLeg: Hashable {
    var id: String
    var origin: DSSAirportEntity
    var destination: DSSAirportEntity
    var durationInMinutes: Int
    var flightNumber: String?
    var stopCount: Int
    var departure: String
    var arrival: String
    var timeDeltaInDays: Int
    var carriers: DCarrier
    var segments: [DSSSegment]
    
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
    var marketing: [DSSMarketing]
    var operationType: String
    
    init(marketing: [DSSMarketing], operationType: String) {
        self.marketing = marketing
        self.operationType = operationType
    }
}

@Model
class DSSMarketing: Hashable {
    var logoUrl: String
    var name: String
    
    init(logoUrl: String, name: String) {
        self.logoUrl = logoUrl
        self.name = name
    }
}

@Model
class DSSAirportEntity: Hashable {
    var id: String
    var entityId: String
    var name: String
    var displayCode: String
    var city: String
    var country: String
    
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
    var id: String
    var origin: DSSRoute
    var destination: DSSRoute
    var departure: String
    var arrival: String
    var durationInMinutes: Int
    var flightNumber: String
    var marketingCarrier: DSSCarrier
    
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
    var name: String
    var alternateId: String
    
    init(name: String, alternateId: String) {
        self.name = name
        self.alternateId = alternateId
    }
}

@Model
class DSSRoute: Hashable {
    var flightPlaceId: String
    var name: String
    var type: String
    var country: String
    var parent: DSSRouteParent
    
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
    var flightPlaceId: String
    var displayCode: String
    var name: String
    var type: String
    
    init(flightPlaceId: String, displayCode: String, name: String, type: String) {
        self.flightPlaceId = flightPlaceId
        self.displayCode = displayCode
        self.name = name
        self.type = type
    }
}
