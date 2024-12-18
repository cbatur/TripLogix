
import Foundation

struct Location: Codable, Hashable, Identifiable {
    /// sourcery:primaryKey
    let id: Int
    let place_id: String
    let name: String
    let formatted_address: String
    let lat: Double
    let lng: Double
    let icon: String
    //let place_saved: Bool
}

struct GooglePlace: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    let htmlAttributions: [String]
    let result: PlaceResult
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case result, status
    }
    
    static func == (lhs: GooglePlace, rhs: GooglePlace) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Define the structure of the result object
struct PlaceResult: Decodable, Encodable, Identifiable, Equatable {
    var id = UUID() // Excluded from Codable
    let formattedAddress: String
    let formattedPhoneNumber: String
    let userRatingsTotal: Int
    let rating: Double
    let geometry: PlaceGeometry
    let icon: String
    let iconBackgroundColor: String
    let name: String
    let photos: [PlacePhoto]
    let place_id: String
    let vicinity: String
    
    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case userRatingsTotal = "user_ratings_total"
        case geometry, icon, name, place_id, photos, vicinity, rating
        case iconBackgroundColor = "icon_background_color"
        // Notice `id` is not listed here, so it's excluded from Codable
    }
    
    static func == (lhs: PlaceResult, rhs: PlaceResult) -> Bool {
        return lhs.place_id == rhs.place_id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(place_id)
    }
}

// Define the geometry structure
struct PlaceGeometry: Codable {
    let location: PlaceLocation
}

// Define the location structure
struct PlaceLocation: Codable {
    let lat: Double
    let lng: Double
}

// Define the photos structure
struct PlacePhoto: Codable {
    let photoReference: String
    let width: Int
    
    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
        case width
    }
}

// Google Places API - New
struct GooglePlaceMaskedResponse: Decodable, Encodable {
    
    let places: [GooglePlaceMasked]
    
    struct GooglePlaceMasked: Decodable, Encodable, Hashable, Identifiable {
        
        let id: String
        let formattedAddress: String?
        let displayName: DisplayName?
        
        static func == (lhs: GooglePlaceMasked, rhs: GooglePlaceMasked) -> Bool {
            return lhs.id == rhs.id && lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    struct DisplayName: Decodable, Encodable {
        let text: String
        let languageCode: String
    }
}

