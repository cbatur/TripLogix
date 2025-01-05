import Foundation
import SwiftData

@Model
class Itinerary: Hashable {
    var index: Int
    var title: String
    var date: String
    var activities: [EventItem]

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
    var index: Int
    var title: String
    var categories: [String]
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
    var index: Int
    var categories: [EventCategorySD]

    init(index: Int, categories: [EventCategorySD]) {
        self.index = index
        self.categories = categories
    }

    static func == (lhs: AllEventsSD, rhs: AllEventsSD) -> Bool {
        return lhs.index == rhs.index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

@Model
class EventCategorySD: Hashable {
    var index: Int
    var category: String
    var events: [String]
    
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
