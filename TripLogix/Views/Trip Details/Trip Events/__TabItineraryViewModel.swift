import Combine
import Foundation
import UIKit
import SwiftUI

final class TripPlanViewModel: ObservableObject {
    
    @Published var allEvents: [EventCategory] = []
    @Published var itineraries: [DayItinerary] = []
    @Published var activeAlertBox: AlertBoxMessage?
    private var apiCount: Int = 0

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
            startService(city)
            serviceDailyPlan(qType: qType)
        }
    }
      
    func serviceGooglePlaces(textQuery: String) -> AnyPublisher<GooglePlaceMaskedResponse, Error> {
        googleAPIService.placeSearchText(fieldMask: "*", textQuery: textQuery)
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
                self.itineraries = newItineraries
            }
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
    
}
