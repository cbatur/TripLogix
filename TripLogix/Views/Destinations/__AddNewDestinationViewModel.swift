import Combine
import Foundation
import UIKit
import SwiftUI

struct PlaceWithPhoto: Identifiable, Equatable {
    var id: String = UUID().uuidString
    let googlePlace: GooglePlace
    let imageData: Data?
    
    static func == (lhs: PlaceWithPhoto, rhs: PlaceWithPhoto) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum LocationCatalog {
    case recentSearches
    case wishlist
    case visited
}
//
final class AddNewDestinationViewModel: ObservableObject {
    
    @Published var query = ""
    @Published private(set) var suggestions: [GooglePlacesResponse.Prediction] = []
    @Published var selectedLocation: PlaceWithPhoto?
    @Published var popularLocations = [PlaceWithPhoto]()
    
    // Recent Searches
    var cachedRecentSearches = [GooglePlace]()
    @Published var cachedTilesRecentSearches = [PlaceWithPhoto]()
    
    // Wishlist
    var cachedWishlist = [GooglePlace]()
    @Published var cachedTilesWishlist = [PlaceWithPhoto]()

    @Published var activeAlertBox: AlertBoxMessage?
    private var apiCount: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    private let gpAPIService = GooglePlacesAPIService()
    private let tlAPIService = TLAPIService()
    
    init() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { (queryString) -> AnyPublisher<[GooglePlacesResponse.Prediction], Never> in
                if queryString.count < 3 {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.fetchAutocomplete(queryString)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .assign(to: &$suggestions)
    }
    
    private func fetchAutocomplete(_ query: String) -> AnyPublisher<[GooglePlacesResponse.Prediction], Error> {

        guard let apiKey = decryptAPIKey(.googlePlaces) else { preconditionFailure("Bad API Key") }

        let path = "place/autocomplete/json?input=\(query)&types=(cities)&key=\(apiKey)"
        let urlString = "\(Configuration.GooglePlaces.baseUrl)\(path)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GooglePlacesResponse.self, decoder: JSONDecoder())
            .map { response in
                response.predictions.map { $0 }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchLocation(with placeId: String) async {
        do {
            let place = try await fetchPlaceDetails(placeId: placeId)
            
            // Cache the place on the main thread
            await MainActor.run {
                self.cachePlace(place, catalog: .recentSearches)
            }
        } catch {
            await MainActor.run {
                // Handle error (e.g., update error state in the UI)
                print("[Debug] Failed to fetch place details: \(error.localizedDescription)")
            }
        }
    }

    func fetchPlaceDetails(placeId: String) async throws -> GooglePlace {
        let request = TLRequests.GooglePlace(googlePlaceId: placeId).request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Log the raw response data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[Debug] Raw API Response: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(GooglePlace.self, from: data)
    }
    
    // -----------------------------------
    // Manage caching Google Places    
    // -----------------------------------
    func cachePlace(_ place: GooglePlace?, catalog: LocationCatalog) {
        guard let p = place else { return }
        
        switch catalog {
        case .recentSearches:
            getCachedSearchedPlaces()
            
            if !self.cachedRecentSearches.contains(where: {
                $0.result.place_id == p.result.place_id
            }) {
                self.cachedRecentSearches.append(p)
                self.convertSinglePlace(p)
            }

            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.cachedRecentSearches) {
                UserDefaults.standard.set(encoded, forKey: "recentSearches")
            }
        case .wishlist:
            getCachedWishlistPlaces()
            
            if !self.cachedWishlist.contains(where: {
                $0.result.place_id == p.result.place_id
            }) {
                self.cachedWishlist.append(p)
                self.convertSingleWishlistPlace(p)
            
            }

            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.cachedWishlist) {
                UserDefaults.standard.set(encoded, forKey: "locationWishlist")
            }
        default:
            break;
        }
    }
    
    func removeOlderRecords() {
        // Keeps the last 12 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedRecentSearches.prefix(12))) {
            UserDefaults.standard.set(encoded, forKey: "recentSearches")
        }
    }
    
    func removeOlderWishlistRecords() {
        // Keeps the last 12 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedWishlist.prefix(20))) {
            UserDefaults.standard.set(encoded, forKey: "locationWishlist")
        }
    }
    
    func getCachedSearchedPlaces() {
        self.cachedTilesRecentSearches = []
        if let savedObjects = UserDefaults.standard.object(forKey: "recentSearches") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([GooglePlace].self, from: savedObjects) {
                self.cachedRecentSearches = loadedObjects.reversed()
                removeOlderRecords()
                convertCachedPlaces(.recentSearches)
            } else { return }
        } else { return }
    }
    
    func getCachedWishlistPlaces() {
        self.cachedTilesWishlist = []
        if let savedObjects = UserDefaults.standard.object(forKey: "locationWishlist") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([GooglePlace].self, from: savedObjects) {
                self.cachedWishlist = loadedObjects.reversed()
                removeOlderWishlistRecords()
                convertCachedPlaces(.wishlist)
            } else { return }
        } else { return }
    }
    
    func getPopularPlaces() async {
        do {
            let places = try await popularPlacesAPI()
            
            // Cache the place on the main thread
            await MainActor.run {
                for place in places {
                    self.createSinglePlace(place)
                }
            }
        } catch {
            await MainActor.run {
                // Handle error (e.g., update error state in the UI)
                print("[Debug] Failed to fetch place details: \(error.localizedDescription)")
            }
        }
    }

    func popularPlacesAPI() async throws -> [GooglePlace] {
        let request = TLRequests.GetPopularGooglePlaces().request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Log the raw response data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[Debug] Raw API Response: popularPlacesAPI() \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([GooglePlace].self, from: data)
    }
    
    // Converts GooglePlace into PlaceWithPhoto to be used in cards
    func createSinglePlace(_ place: GooglePlace) {
        let group = DispatchGroup()
        group.enter()
        loadImage(place) { placeWithPhoto in
            if let photo = placeWithPhoto {
                DispatchQueue.main.async {
                    self.popularLocations.append(photo)
                }
            }
            group.leave()
        }
    }

    func convertSinglePlace(_ place: GooglePlace) {
        let group = DispatchGroup()
        group.enter()
        loadImage(place) { placeWithPhoto in
            if let photo = placeWithPhoto {
                DispatchQueue.main.async {
                    self.selectedLocation = photo
                    self.cachedTilesRecentSearches.append(photo)
                }
            }
            group.leave()
        }
    }
    
    func convertSingleWishlistPlace(_ place: GooglePlace) {
        loadImage(place) { placeWithPhoto in
            if let photo = placeWithPhoto {
                DispatchQueue.main.async {
                    //self.selectedLocation = photo
                    self.cachedTilesWishlist.append(photo)
                }
            }
        }
    }

    func convertCachedPlaces(_ catalog: LocationCatalog) {
        switch catalog {
        case .recentSearches:
            for place in self.cachedRecentSearches {
                loadImage(place) { placeWithPhoto in
                    if let photo = placeWithPhoto {
                        DispatchQueue.main.async {
                            self.cachedTilesRecentSearches.append(photo)
                        }
                    }
                }
            }
        case .wishlist:
            for place in self.cachedWishlist {
                loadImage(place) { placeWithPhoto in
                    if let photo = placeWithPhoto {
                        DispatchQueue.main.async {
                            self.cachedTilesWishlist.append(photo)
                        }
                    }
                }
            }
        default:
            break;
            // Add Visited Trips Later
        }
    }
    // -----------------------------------
    // End caching Google Places
    // -----------------------------------
    
    func loadImage(_ googlePlace: GooglePlace, completion: @escaping (PlaceWithPhoto?) -> Void) {
        guard let photoReference = googlePlace.result.photos?.first?.photoReference else {
            completion(nil)
            return
        }
        guard let apiKey = decryptAPIKey(.googlePlaces) else {
            preconditionFailure("Bad API Key")
        }
        let maxWidth = 400
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(photoReference)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    completion(PlaceWithPhoto(googlePlace: googlePlace, imageData: data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

//    func selectSuggestion(_ suggestion: GooglePlacesResponse.Prediction) async {
//        await self.searchLocation(with: suggestion.place_id)
//        self.query = suggestion.description
//        self.suggestions = []
//    }
    
    func selectSuggestion(_ suggestion: GooglePlacesResponse.Prediction) async {
        await MainActor.run {
            self.query = suggestion.description
            self.suggestions = []
        }
        
        await searchLocation(with: suggestion.place_id)
    }
    
    func resetSearch() {
        self.query = ""
        self.suggestions = []
    }

}

struct GooglePlacesResponse: Codable {
    let predictions: [Prediction]
    
    struct Prediction: Codable, Hashable {
        let description: String
        let place_id: String
    }
}
