import Combine
import Foundation
import UIKit
import SwiftUI

@MainActor
final class EventViewModel: ObservableObject {
    
    @Published var cachedGoogleLocations: [GooglePlace] = []
    @Published var photosFromDatabase: PhotosResponse?
    @Published var googlePlace: GooglePlace?
    @Published var allEvents: [EventCategory] = []
    @Published var itineraries: [DayItinerary] = []
    @Published var activeAlertBox: AlertBoxMessage?
    @Published var allTags: [String] = []
    private var apiCount: Int = 0
    private var city: String = ""

    private var cancellableSet: Set<AnyCancellable> = []
    private let openAIAPIService = OpenAIAPIService()
    private let googleAPIService = GooglePlacesAPIService()
    private let tlAPIService = TLAPIService()
    
    func generateAllEvents(qType: QCategory) {
        if case .getDailyPlan(let city, _, _) = qType {
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
        if case .getDailyPlan(let city, _, _) = qType {
            self.city = city
            startService(city)
            serviceDailyPlan(qType: qType)
        }
    }
    
    func getCityEventCategories(qType: QCategory) {
        openAIAPIService.openAPICommand(qType: qType)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.activeAlertBox = .error("Something went wrong, try again.")
                }
            }, receiveValue: {
                guard let eventCategories = $0.choices.first?.message.content else { return }
                if let jsonData = eventCategories.data(using: .utf8) {
                    do {
                        let items = try JSONDecoder().decode([String].self, from: jsonData)
                        self.allTags = items
                    } catch {

                    }
                }
            })
            .store(in: &cancellableSet)
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
        let group = DispatchGroup()
        var newItineraries = [DayItinerary]()
        
        for day in e {
            let updatedActivities = addGooglePlaceIdToActivities(day.activities, group: group)
            
            group.notify(queue: .main) {
                let newDay = DayItinerary(
                    index: day.index,
                    title: day.title,
                    date: day.date,
                    activities: updatedActivities
                )
                newItineraries.append(newDay)
                self.itineraries = newItineraries
            }
        }
    }

    private func addGooglePlaceIdToActivities(_ activities: [Activity], group: DispatchGroup) -> [Activity] {
        var updatedActivities = [Activity]()
        
        for activity in activities {
            if !activity.title.isEmpty {
                group.enter()
                serviceGooglePlaces(textQuery: activity.title)
                    .sink(receiveCompletion: { _ in }, receiveValue: { place in
                        let googlePlaceId = self.googlePlaceIdNeeded(activity) ? place.places.first?.id ?? "" : ""
                        DispatchQueue.main.async {
                            updatedActivities.append(Activity(
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
        }
        
        return updatedActivities
    }
    
//    func addGooglePlaceId(_ e: [DayItinerary]) {
//        var newItineraries = [DayItinerary]()
//        
//        let group = DispatchGroup()
//        
//        for day in e {
//            var newActivities = [Activity]()
//            
//            for activity in day.activities {
//                
//                if !activity.title.isEmpty {
//                    
//                    group.enter()
//                    serviceGooglePlaces(textQuery: activity.title)
//                        .sink(receiveCompletion: { _ in }, receiveValue: { place in
//                            
//                            let googlePlaceId = self.googlePlaceIdNeeded(activity) ? place.places.first?.id ?? "" : ""
//                                                        
//                            DispatchQueue.main.async {
//                                newActivities.append(Activity(
//                                    index: activity.index,
//                                    title: activity.title,
//                                    googlePlaceId: googlePlaceId,
//                                    googlePlace: activity.googlePlace,
//                                    categories: activity.categories
//                                ))
//                                group.leave()
//                            }
//                        })
//                        .store(in: &cancellableSet)
//                }
//            }
//            
//            group.notify(queue: .main) {
//                let newDay = DayItinerary(
//                    index: day.index,
//                    title: day.title,
//                    date: day.date,
//                    activities: newActivities
//                )
//                newItineraries.append(newDay)
//                self.loopItineraries(newItineraries)
//            }
//        }
//    }
    
    // MARK - Persisting Google Places
    // cache single Place by PlaceId - from location details
    func cacheSingleGoogleLocation(_ googlePlaceId: String) {
        completeGooglePlaces(googlePlaceId)
            .sink(receiveCompletion: { _ in }, receiveValue: { place in
                self.googlePlace = place
                self.manageGooglePlaceCache(place)
            })
            .store(in: &cancellableSet)
    }

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
        
        group.notify(queue: .main) {
            self.itineraries = e
        }
    }
    
//    func loopItineraries(_ e: [DayItinerary]) {
//        let group = DispatchGroup()
//        
//        for day in e {            
//            for activity in day.activities {
//                group.enter()
//                completeGooglePlaces(activity.googlePlaceId)
//                    .sink(receiveCompletion: { _ in }, receiveValue: { place in
//                        DispatchQueue.main.async {
//                            self.manageGooglePlaceCache(place)
//                            group.leave()
//                        }
//                    })
//                    .store(in: &cancellableSet)
//            }
//        }
//        
//        self.itineraries = e
//    }
    
    func addSingleGooglePlace(_ googlePlaceId: String) {
        let group = DispatchGroup()
        group.enter()
        completeGooglePlaces(googlePlaceId)
            .sink(receiveCompletion: { _ in }, receiveValue: { place in
                DispatchQueue.main.async {
                    self.manageGooglePlaceCache(place)
                    group.leave()
                }
            })
            .store(in: &cancellableSet)
    }
    
    
    // API Call to Get the Google Place
//    func completeGooglePlacesOld(_ placeId: String) -> AnyPublisher<GooglePlace, Error> {
//        googleAPIService.searchGooglePlaceId(placeId: placeId)
//            .map { response in
//                response
//            }
//            .mapError { $0 as Error }
//            .eraseToAnyPublisher()
//    }
    
    func completeGooglePlaces(_ placeId: String) -> AnyPublisher<GooglePlace, Error> {
        tlAPIService.searchGooglePlaceId(placeId: placeId)
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
        if let encoded = try? encoder.encode(Array(self.cachedGoogleLocations.prefix(500))) {
            UserDefaults.standard.set(encoded, forKey: "savedGooglePlaces")
        }
    }
    
    // Cache Google Place
    func manageGooglePlaceCache(_ p: GooglePlace) {
        getCachedGooglelocations()
        
        if !self.cachedGoogleLocations.contains(where: {
            $0.result.place_id == p.result.place_id
        }) {
            print("[Debug] doesnt exist: \(p.result.place_id)")
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

// Methods for Photos
extension EventViewModel {
    
//    func fetchPhotosById(placeId: String) async {
//        do {
//            // Check for cached photos from the backend
//            if let cachedPhotos = try await fetchCachedPhotos(placeId: placeId), !cachedPhotos.isEmpty {
//                DispatchQueue.main.async {
//                    self.photosFromDatabase = PhotosResponse(photos: cachedPhotos)
//                }
//                return
//            }
//
//            // If no cached photos, call manageGooglePlaces.php
//            let manageRequest = TLRequests.GooglePlace(googlePlaceId: placeId).request
//            let (data, response) = try await URLSession.shared.data(for: manageRequest)
//
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                throw URLError(.badServerResponse)
//            }
//
//            // Decode the full response, process photos, and cache them
//            let apiResponse = try JSONDecoder().decode(GooglePlace.self, from: data)
//
//            if let photos = apiResponse.result.photos {
//                await cachePhotosToDatabase(photos, placeId: placeId)
//            }
//        } catch {
//            print("Error fetching photos: \(error)")
//        }
//    }
    
    func fetchPhotosById(placeId: String) async {
        do {
            // Attempt to fetch cached photos
            let cachedPhotos = try await fetchCachedPhotos(placeId: placeId)
            if !cachedPhotos.isEmpty {
                DispatchQueue.main.async {
                    self.photosFromDatabase = PhotosResponse(photos: cachedPhotos)
                }
                return
            }

            // If no cached photos, fetch new ones and cache
            let apiResponse = try await fetchGooglePlace(placeId: placeId)
            if let photos = apiResponse.result.photos {
                let mappedPhotos = photos.map { placePhoto in
                    Photo(
                        imageUrl: placePhoto.imageUrl ?? "",
                        localFilePath: nil
                    )
                }
                await cachePhotosToDatabase(mappedPhotos, placeId: placeId)
            }
        } catch {
            print("Error fetching photos: \(error)")
        }
    }

    private func fetchGooglePlace(placeId: String) async throws -> GooglePlace {
        let request = TLRequests.GooglePlace(googlePlaceId: placeId).request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(GooglePlace.self, from: data)
    }

    private func fetchCachedPhotos(placeId: String) async throws -> [Photo] {
        let fetchRequest = TLRequests.FetchPhotos(googlePlaceId: placeId).request
        let (data, response) = try await URLSession.shared.data(for: fetchRequest)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return []
        }

        let cachedPhotosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
        return cachedPhotosResponse.photos
    }

    private func cachePhotosToDatabase(_ photos: [Photo], placeId: String) async {
        for photo in photos {
            if let localPath = await downloadAndCachePhoto(photo.imageUrl, googlePlaceId: placeId) {
                DispatchQueue.main.async {
                    var updatedPhotos = self.photosFromDatabase?.photos ?? []
                    updatedPhotos.append(Photo(imageUrl: photo.imageUrl, localFilePath: localPath))
                    self.photosFromDatabase = PhotosResponse(photos: updatedPhotos)
                }
            }
        }
    }

    private func downloadAndCachePhoto(_ imageUrl: String, googlePlaceId: String) async -> String? {
        guard let url = URL(string: imageUrl) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            // Save to local temp directory
            let localPath = saveToTempDirectory(data)

            return localPath
        } catch {
            print("Failed to download photo: \(error)")
            return nil
        }
    }

    private func saveToTempDirectory(_ data: Data) -> String {
        let fileName = UUID().uuidString
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Failed to save photo to temp directory: \(error)")
            return ""
        }
    }
    

}

// Methods that require Destination
extension EventViewModel {
    
    // Get all initial categories for first time locations.
    func fetchEventCategoriesIfNeeded(_ destination: Destination) {
        if destination.allEventTags.count == 0 {
            self.getCityEventCategories(
                qType: .getEventCategories(
                    city: destination.name
                )
            )
        }
    }
    
    // Initiate "Get itinerary" items
    func updateTrip(_ destination: Destination) {
        self.generateItinerary(
            qType: .getDailyPlan(
                city: destination.name,
                dateRange: self.parseDateRange(destination),
                tripsExtension: self.flightsExtension(destination)
            )
        )
    }
    
    func tripsExtension(_ destination: Destination) -> String {
        if destination.selectedEventTags.count == 0 {
            return ""
        } else {
            return "Fetch events the following categories -> " + destination.selectedEventTags.joined(separator: ",")
        }
    }
    
    // Attach Flight extension If applicable and If user agrees
    func flightsExtension(_ destination: Destination) -> String {
        if destination.flights.isEmpty {
            return ""
        } else {
            return "This is my flights info, consider them when creating my itinerary -> " + convertFlightsToString(destination.flights)
        }
    }
    
    // Create a function to convert array of DSelectedFlight to the desired string
    func convertFlightsToString(_ flights: [DSelectedFlight]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"

        let flightsDescriptions = flights.map { flight -> String in
            let dateStr = dateFormatter.string(from: flight.date)
            let departureCode = flight.flight.departure.iataCode
            let arrivalCode = flight.flight.arrival.iataCode
            let flightNumber = flight.flight.airline.iataCode + "-" + flight.flight.flight.number
            return "\(dateStr) - airline number \(flightNumber) from \(departureCode) to \(arrivalCode)"
        }

        return flightsDescriptions.joined(separator: ", ")
    }

    // Custom categories string to attach to the query
    func eventsExtension(_ destination: Destination) -> String {
        if destination.selectedEventTags.count == 0 {
            return ""
        } else {
            return "Fetch events the following categories -> " + destination.selectedEventTags.joined(separator: ",")
        }
    }
    
    func parseDateRange(_ destination: Destination) -> String {
        let dateRange = "\(destination.startDate.formatted(date: .long, time: .omitted)) and \(destination.endDate.formatted(date: .long, time: .omitted))"
        return dateRange
    }
    
    // Assign itinerary details from API to SWIFTData Persistent Cache
    func populateEvents(
        itineries: [DayItinerary],
        destination: Destination,
        cacheViewModel: CacheViewModel
    ) {
        let cacheItinerary = CacheItem(
            name: "Itinerary Created - \(destination.id)",
            content: itineries.map { $0.title }.joined(separator: ", ")
        )
        cacheViewModel.addCachedItem(cacheItinerary)
        
        destination.itinerary = []
        for item in itineries {
            var events = [EventItem]()
            for event in item.activities {
                events.append(EventItem(
                    index: event.index,
                    title: event.title,
                    categories: event.categories,
                    googlePlaceId: event.googlePlaceId
                ))
            }
            
            destination.itinerary.append(
                Itinerary(
                    index: item.index,
                    title: item.title,
                    date: item.date,
                    activities: events
                ))
        }
        
        let c = CacheItem(
            name: "Itinerary Added to Destination - \(destination.id)",
            content: destination.itinerary.map { $0.title }.joined(separator: ", ")
        )
        cacheViewModel.addCachedItem(c)
        
    }
}
