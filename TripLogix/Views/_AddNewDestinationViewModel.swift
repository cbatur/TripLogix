import Combine
import Foundation
import UIKit
import SwiftUI

struct PlaceWithPhoto: Identifiable {
    var id: String = UUID().uuidString
    let googlePlace: GooglePlace
    let imageData: Data?
}

final class AddNewDestinationViewModel: ObservableObject {
    
    @Published var query = ""
    @Published private(set) var suggestions: [GooglePlacesResponse.Prediction] = []
    @Published var gpLocation: GooglePlace?
    @Published var cachedPlaces = [GooglePlace]()
    @Published var cachedPhotos = [PlaceWithPhoto]()

    @Published var activeAlertBox: AlertBoxMessage?
    private var apiCount: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    private let openAIAPIService = OpenAIAPIService()
    private let gpAPIService = GooglePlacesAPIService()
    
    
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
    
    func searchLocation(with placeId: String) {
        gpAPIService.searchGooglePlaceId(placeId: placeId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] place in
                self?.cachePlace(place)
            })
            .store(in: &cancellables)
    }
    
    // -----------------------------------
    // Manage caching Google Places    
    // -----------------------------------
    func cachePlace(_ place: GooglePlace?) {
        guard let p = place else { return }
        getCachedPlaces()
        
        if !self.cachedPlaces.contains(where: {
            $0.result.place_id == p.result.place_id
        }) {
            self.cachedPlaces.append(p)
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.cachedPlaces) {
            UserDefaults.standard.set(encoded, forKey: "cachedPlaces")
        }
    }
    
    func removeOlderRecords() {
        // Keeps the last 20 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedPlaces.prefix(19))) {
            UserDefaults.standard.set(encoded, forKey: "cachedPlaces")
        }
    }
    
    func getCachedPlaces() {
        if let savedObjects = UserDefaults.standard.object(forKey: "cachedPlaces") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([GooglePlace].self, from: savedObjects) {
                self.cachedPlaces = loadedObjects.reversed()
                removeOlderRecords()
                convertCachedPlaces()
            } else { return }
        } else { return }
    }
    
    func convertCachedPlaces() {
        for place in self.cachedPlaces {
            loadImage(place)
        }
    }
    // -----------------------------------
    // End caching Google Places
    // -----------------------------------
    
    func loadImage(_ googlePlace: GooglePlace) {
        guard let photoReference = googlePlace.result.photos.first?.photoReference else { return }
        guard let apiKey = decryptAPIKey(.googlePlaces) else { preconditionFailure("Bad API Key") }
        let maxWidth = 400 // Example width, adjust as needed
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(photoReference)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.cachedPhotos.append(PlaceWithPhoto(googlePlace: googlePlace, imageData: data))
            }
        }.resume()
    }

    func selectSuggestion(_ suggestion: GooglePlacesResponse.Prediction) {
        searchLocation(with: suggestion.place_id)
        self.query = suggestion.description
        self.suggestions = []
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
