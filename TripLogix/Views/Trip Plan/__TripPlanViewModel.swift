import Combine
import Foundation
import UIKit
import SwiftUI

final class TripPlanViewModel: ObservableObject {
    
    @Published var cachedGoogleLocations: [GooglePlace] = []
    @Published var allEvents: [EventCategory] = []
    @Published var itineraries: [DayItinerary] = []
    @Published var activeAlertBox: AlertBoxMessage?
    private var apiCount: Int = 0
    private var city: String = ""

    private var cancellableSet: Set<AnyCancellable> = []
    private let openAIAPIService = OpenAIAPIService()
    private let googleAPIService = GooglePlacesAPIService()
    
    func generateAllEvents(qType: QCategory) {
        if case .getDailyPlan(let city, _) = qType {
            startService(city)
            serviceDailyPlan(qType: qType)
        }
    }
    
    func serviceAllEvents(qType: QCategory) {
        openAIAPIService.openAPICommand(qType: qType)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.activeAlertBox = AlertBoxMessage.error("Something Went Wrong! Please try again.")
                }
            }, receiveValue: {
                guard let questionSet = $0.choices.first?.message.content else { return }
                
                if let jsonData = questionSet.data(using: .utf8) {
                    do {
                        let items = try JSONDecoder().decode([EventCategory].self, from: jsonData)
                        self.allEvents = items
                        self.activeAlertBox = nil
                        self.apiCount = 0
                    } catch {
                        if self.apiCount < 4 {
                            self.generateItinerary(qType: qType)
                        } else {
                            self.activeAlertBox = AlertBoxMessage.error("Something Went Wrong! Please try again.")
                        }
                    }
                }
            })
            .store(in: &cancellableSet)
    }
    
    func generateItinerary(qType: QCategory) {
        if case .getDailyPlan(let city, _) = qType {
            self.city = city
            startService(city)
            serviceDailyPlan(qType: qType)
        }
    }
    
    // Get the photo URL from Google Place Object
    func urlForPhoto(reference: String) -> String {
        guard let googleAPIKey = decryptAPIKey(.googlePlaces) else { return "" }
        return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(reference)&key=\(googleAPIKey)"
    }
    
    func serviceGooglePlaces(textQuery: String) -> AnyPublisher<GooglePlaceMaskedResponse, Error> {
        googleAPIService.placeSearchText(fieldMask: "*", textQuery: "\(textQuery) \(self.city)")
            .map { response in
                response
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func googlePlaceIdNeeded(_ activity: Activity) -> Bool {
        if activity.categories.contains("checkin") || activity.categories.contains("checkout") {
            return false
        } else {
            return true
        }
    }
    
    func addGooglePlaceId(_ e: [DayItinerary]) {
        var newItineraries = [DayItinerary]()
        
        let group = DispatchGroup()
        
        for day in e {
            var newActivities = [Activity]()
            
            for activity in day.activities {
                group.enter()
                serviceGooglePlaces(textQuery: activity.title)
                    .sink(receiveCompletion: { _ in }, receiveValue: { place in
                        
                        let googlePlaceId = self.googlePlaceIdNeeded(activity) ? place.places.first?.id ?? "" : ""
                        
                        DispatchQueue.main.async {
                            newActivities.append(Activity(
                                index: activity.index,
                                title: activity.title,
                                googlePlaceId: googlePlaceId,
                                googlePlace: activity.googlePlace,
                                categories: activity.categories
                            ))
                            group.leave()
                        }
                    })
                    .store(in: &cancellableSet)
            }
            
            group.notify(queue: .main) {
                let newDay = DayItinerary(
                    index: day.index,
                    title: day.title,
                    date: day.date,
                    activities: newActivities
                )
                newItineraries.append(newDay)
                self.loopItineraries(newItineraries)
            }
        }
    }
    
    // MARK - Persisting Google Places
    // Loop through the itineraries to cache Place by PlaceId
    func loopItineraries(_ e: [DayItinerary]) {
        let group = DispatchGroup()
        
        for day in e {            
            for activity in day.activities {
                group.enter()
                completeGooglePlaces(activity.googlePlaceId)
                    .sink(receiveCompletion: { _ in }, receiveValue: { place in
                        DispatchQueue.main.async {
                            self.manageGooglePlaceCache(place)
                            group.leave()
                        }
                    })
                    .store(in: &cancellableSet)
            }
        }
        
        self.itineraries = e
    }
    
    // API Call to Get the Google Place
    func completeGooglePlaces(_ placeId: String) -> AnyPublisher<GooglePlace, Error> {
        googleAPIService.searchGooglePlaceId(placeId: placeId)
            .map { response in
                response
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func getCachedGooglelocations() {
        self.cachedGoogleLocations = []
        if let savedObjects = UserDefaults.standard.object(forKey: "savedGooglePlaces") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([GooglePlace].self, from: savedObjects) {
                self.cachedGoogleLocations = loadedObjects
                removeOlderGooglePlaces()
            } else { return }
        } else { return }
    }
    
    func removeOlderGooglePlaces() {
        // Keeps the last 100 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedGoogleLocations.prefix(100))) {
            UserDefaults.standard.set(encoded, forKey: "savedGooglePlaces")
        }
    }
    
    // Cache Google Place
    func manageGooglePlaceCache(_ p: GooglePlace) {
        getCachedGooglelocations()
        
        if !self.cachedGoogleLocations.contains(where: {
            $0.result.place_id == p.result.place_id
        }) {
            self.cachedGoogleLocations.append(p)
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.cachedGoogleLocations) {
            UserDefaults.standard.set(encoded, forKey: "savedGooglePlaces")
        }        
    }
    
    func serviceDailyPlan(qType: QCategory) {
        openAIAPIService.openAPICommand(qType: qType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: {
                guard let questionSet = $0.choices.first?.message.content else { return }
                
                if let jsonData = questionSet.data(using: .utf8) {
                    do {
                        let items = try JSONDecoder().decode([DayItinerary].self, from: jsonData)
                        self.addGooglePlaceId(items)
                        self.activeAlertBox = nil
                        self.apiCount = 0
                    } catch {
                        if self.apiCount < 4 {
                            self.generateItinerary(qType: qType)
                        } else {
                            self.activeAlertBox = AlertBoxMessage.error("Something Went Wrong! Please try again.")
                        }
                    }
                }
            })
            .store(in: &cancellableSet)
    }
    
    func startService(_ city: String) {
        if apiCount == 0 {
            activeAlertBox = AlertBoxMessage.dayTripInitial(city)
        } else if apiCount == 1 {
            activeAlertBox = AlertBoxMessage.dayTripInitial2
        } else {
            activeAlertBox = AlertBoxMessage.dayTripInitial3(city)
        }
        apiCount = apiCount + 1
    }
    
    func showUpdateButton() -> Bool {
        return activeAlertBox == nil ||
        activeAlertBox != .error("Something Went Wrong! Please try again.")
    }
    
    func displayDailyDate(_ stringDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: stringDate) else {
            return "Invalid date"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE, MMM d"
        outputFormatter.locale = Locale(identifier: "en_US")
        let formattedDate = outputFormatter.string(from: date)
        return formattedDate
    }
}
