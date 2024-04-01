import Combine
import Foundation
import UIKit
import SwiftUI

final class ImageToFlightViewModel: ObservableObject {
    @Published var selectedImage: Image? = nil
    @Published var showImagePicker: Bool = false
    @Published var flightsFromImage: [AEFutureFlightParams] = []
    @Published var futureFlights = [SelectedFlightGroup]()
    @Published var selectedFlights: [Int: SelectedFlight] = [:]
    @Published var flightImageUrl: String?
    @Published var flightVerificationString: String?
    @Published var activeAlertBox: AlertBoxMessage?
    private var apiCount: Int = 0

    private var cancellableSet: Set<AnyCancellable> = []

    private let openAIAPIService = OpenAIAPIService()
    private let tlAPIService = TLAPIService()
    private let aviationEdgeAPIService = AviationEdgeAPIService()
    
    // Additional methods and logic...
    func activity() -> Bool {
        (
            activeAlertBox != nil && activeAlertBox != .reservationInThePast && activeAlertBox != .imageNotSerialized && activeAlertBox != .error
        )
    }
    
    func getVerificationString() -> String {
        var infoString = ""
        _ = selectedFlights.map { (key: Int, flight: SelectedFlight) in
            infoString = infoString + simplfyFlightInfo(flight)
        }
        return infoString
    }
    
    private func simplfyFlightInfo(_ f: SelectedFlight) -> String {
        return "\(f.flight.departure.iataCode.uppercased()) ➔ \(f.flight.arrival.iataCode.uppercased()) - \(f.flight.airline.iataCode.uppercased()) \(f.flight.flight.number)\n"
    }
    
    func hasFlights() -> Bool {
        return selectedFlights.count > 0
    }

    // Select a flight within a specific group
    func selectFlight(flightToSelect: AEFutureFlight, inGroupAtIndex index: Int) {
        // Ensure the index is within bounds
        guard futureFlights.indices.contains(index) else { return }

        let group = futureFlights[index]
        if group.flights.contains(where: { $0.id == flightToSelect.id }) {
            let newSelectedFlight = SelectedFlight(flight: flightToSelect, selected: true)
            selectedFlights[index] = newSelectedFlight
        }
    }

    func uploadSelectedImage() {
        guard let uiImage = selectedImage?.asUIImage() else { return }
        guard let imageData = uiImage.jpegData(compressionQuality: 0.1) else { return }
        let imageString = imageData.base64EncodedString()
        let imageName = "\(UUID().uuidString)"
        uploadFlightPhoto(imageName: imageName, imageString: imageString)
    }
    
    func checkIfPastDate(from flightSet: [AEFutureFlightParams]) {
        guard let firstRound = flightSet.first else { return }
        let dateString = firstRound.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString), date <= Date() {
            selectedImage = nil
            activeAlertBox = AlertBoxMessage.reservationInThePast
        } else {
            selectedImage = nil
            for flight in flightSet {
                getFutureFlights(flight)
            }
        }
    }
    
    func resetSearch() {
        flightsFromImage = []
        futureFlights = []
        selectedFlights = [:]
        selectedImage = nil
        activeAlertBox = nil
    }
}

extension ImageToFlightViewModel { // API MEthods
    
    // Image uplad to create image-URL
    func uploadFlightPhoto(imageName: String, imageString: String) {
        activeAlertBox = AlertBoxMessage.analyzeImage
        tlAPIService.flightImageUpload(imageName: imageName, imageString: imageString)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.activeAlertBox = AlertBoxMessage.error
                }
            }, receiveValue: { [weak self] tlImageUrl in
                self?.flightImageUrl = tlImageUrl.imageUrl
            })
            .store(in: &cancellableSet)
    }

    // Image URL received and sent to OpenAI to generate sanitized JSON response.
    func getFlightParametersFromImage(_ imageUrl: String) {
        apiCount = apiCount + 1
        activeAlertBox = AlertBoxMessage.imageReceived
        openAIAPIService.openAPICommand4(qType: QCategory.textFromImageUrl(imageUrl: imageUrl))
            .sink(receiveCompletion: {
                _ in
            },
                  receiveValue: { [weak self] chatGPTResponse in
                guard let questionSet = chatGPTResponse.choices.first?.message.content else { return }
                
                if let jsonData = questionSet.data(using: .utf8) {
                    do {
                        let items = try JSONDecoder().decode([AEFutureFlightParams].self, from: jsonData)
                        
                        if items.filter({ flight in
                            flight.iataCode.count == 3 && flight.destinationIataCode?.count == 3
                        }).count > 0 {
                            self?.flightsFromImage = items
                            self?.activeAlertBox = nil
                        } else {
                            self?.apiCount = 0
                            self?.resetSearch()
                            self?.activeAlertBox = .imageNotSerialized
                        }
                    } catch {
                        // Try 3 times and Handle JSON decoding error If any
                        // Image is not serialized into a flight
                        if let count = self?.apiCount,
                           count < 4 {
                            self?.getFlightParametersFromImage(imageUrl)
                        } else {
                            self?.apiCount = 0
                            self?.resetSearch()
                            self?.activeAlertBox = .imageNotSerialized
                        }
                    }
                }
            })
            .store(in: &cancellableSet)
    }

    // Image -> AI -> Response submitted to AE for final results.
    func getFutureFlights(_ futureFlightParams: AEFutureFlightParams) {
        activeAlertBox = AlertBoxMessage.flightsTrackedInImage
        aviationEdgeAPIService.futureFlights(futureFlightParams: futureFlightParams)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.activeAlertBox = AlertBoxMessage.error
                }
            }, receiveValue: { [weak self] flights in
                 let flightSet = flights.filter { flight in
                    flight.arrival.iataCode.lowercased() == futureFlightParams.destinationIataCode?.lowercased() &&
                    !flight.airline.name.isEmpty
                }
                
                guard let date = stringToDate(futureFlightParams.date) else { return }
                self?.futureFlights.append(SelectedFlightGroup(date: date, flights: flightSet))
                self?.activeAlertBox = nil
            })
            .store(in: &cancellableSet)
    }
}
