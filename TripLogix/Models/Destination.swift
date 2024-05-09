
import Foundation
import SwiftData
import UIKit

@Model
class Destination {
    var id: String = UUID().uuidString
    var name: String
    var details: String
    var googlePlaceId: String
    var startDate: Date
    var endDate: Date
    var baseCity: String = "Toronto"
    var priority: Int
    var icon: Data?
    var allEventTags: [String]
    var selectedEventTags: [String]
    @Relationship(deleteRule: .cascade) var allEvents = [AllEventsSD]()
    @Relationship(deleteRule: .cascade) var itinerary = [Itinerary]()
    @Relationship(deleteRule: .cascade) var flights = [DSelectedFlight]()
    @Relationship(deleteRule: .cascade) var flightLegs = [DSSLeg]()
    
    init(
        name: String = "",
        details: String = "",
        googlePlaceId: String = "",
        startDate: Date = .now,
        endDate: Date = .now,
        priority: Int = 2
    ) {
        self.name = name
        self.details = details
        self.googlePlaceId = googlePlaceId
        self.startDate = startDate
        self.endDate = endDate
        self.priority = priority
        self.allEventTags = []
        self.selectedEventTags = []
    }
}
