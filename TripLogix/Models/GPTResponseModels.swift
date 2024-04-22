
import Foundation

struct DayItinerary: Decodable, Hashable {
    let index: Int
    let title: String
    var date: String
    var activities: [Activity]
}

struct Activity: Decodable, Hashable {
    let index: Int
    let title: String
    let googlePlaceId: String
    let googlePlace: GooglePlace?
    let categories: [String]
}

struct VenueInfo: Decodable, Hashable {
    let venueName: String
    let venueDescription: String
    let city: String
    let country: String
    let locationName: String
}
