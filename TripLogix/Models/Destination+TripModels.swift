import Foundation
import SwiftData

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
