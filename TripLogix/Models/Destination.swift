
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

@Model
class Itinerary: Hashable {
    let index: Int
    let title: String
    var date: String
    let activities: [EventItem]

    init(
        index: Int,
        title: String,
        date: String,
        activities: [EventItem]
    ) {
        self.index = index
        self.title = title
        self.date = date
        self.activities = activities
    }

    static func == (lhs: Itinerary, rhs: Itinerary) -> Bool {
        return lhs.index == rhs.index && lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(title)
    }
}

@Model
class EventItem: Hashable {
    let index: Int
    let title: String
    let categories: [String]
    var googlePlaceId: String
    
    init(index: Int, title: String, categories: [String], googlePlaceId: String) {
        self.index = index
        self.title = title
        self.categories = categories
        self.googlePlaceId = googlePlaceId
    }
    
    static func == (lhs: EventItem, rhs: EventItem) -> Bool {
        return lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

@Model
class AllEventsSD: Hashable {
    let index: Int
    //let title: String
    let categories: [EventCategorySD]

    init(index: Int, categories: [EventCategorySD]) {
        self.index = index
        //self.title = title
        self.categories = categories
    }

    static func == (lhs: AllEventsSD, rhs: AllEventsSD) -> Bool {
        return lhs.index == rhs.index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        //hasher.combine(title)
    }
}

@Model
class EventCategorySD: Hashable {
    let index: Int
    let category: String
    let events: [String]
    
    init(index: Int, category: String, events: [String]) {
        self.index = index
        self.category = category
        self.events = events
    }
    
    static func == (lhs: EventCategorySD, rhs: EventCategorySD) -> Bool {
        return lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

// ---------------- Aviation Edge Data ------------------
@Model
class DSelectedFlight: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var date: Date = Date()
    let flight: DFutureFlight
    
    init(date: Date, flight: DFutureFlight) {
        self.date = date
        self.flight = flight
    }

    static func == (lhs: DSelectedFlight, rhs: DSelectedFlight) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class DFutureFlight: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var weekday: String
    var departure: DAirportDetail
    var arrival: DAirportDetail
    var aircraft: DAircraft
    var airline: DAirline
    var flight: DFlight
    
    init(weekday: String, departure: DAirportDetail, arrival: DAirportDetail, aircraft: DAircraft, airline: DAirline, flight: DFlight) {
        self.weekday = weekday
        self.departure = departure
        self.arrival = arrival
        self.aircraft = aircraft
        self.airline = airline
        self.flight = flight
    }
    
    static func == (lhs: DFutureFlight, rhs: DFutureFlight) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


@Model
class DAirline: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var name: String
    var iataCode: String
    var icaoCode: String

    init(name: String, iataCode: String, icaoCode: String) {
        self.name = name
        self.iataCode = iataCode
        self.icaoCode = icaoCode
    }
    
    static func == (lhs: DAirline, rhs: DAirline) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


@Model
class DAirportDetail: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var iataCode: String
    var icaoCode: String
    var terminal: String
    var gate: String
    var scheduledTime: String

    init(iataCode: String, icaoCode: String, terminal: String, gate: String, scheduledTime: String) {
        self.iataCode = iataCode
        self.icaoCode = icaoCode
        self.terminal = terminal
        self.gate = gate
        self.scheduledTime = scheduledTime
    }

    static func == (lhs: DAirportDetail, rhs: DAirportDetail) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class DAircraft: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var modelCode: String
    var modelText: String

    init(modelCode: String, modelText: String) {
        self.modelCode = modelCode
        self.modelText = modelText
    }
    
    static func == (lhs: DAircraft, rhs: DAircraft) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class DFlight: Hashable {
    let id: String = "\(Int(Date().timeIntervalSince1970))"
    var number: String
    var iataNumber: String
    var icaoNumber: String
    
    init(number: String, iataNumber: String, icaoNumber: String) {
        self.number = number
        self.iataNumber = iataNumber
        self.icaoNumber = icaoNumber
    }
    
    static func == (lhs: DFlight, rhs: DFlight) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
