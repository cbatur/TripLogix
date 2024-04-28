
import Foundation
import SwiftUI
import Combine
import MapKit

struct AnotationItem: Identifiable {
    let id: Int
    let userid: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let remoteIcon: String
    let place: Location
}

final class PlacesViewModel: ObservableObject {

    @Published var spinner = false
    @Published var annotations = [AnotationItem]()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 43.6582232,
            longitude: -79.36996829999998),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1)
    )
    
    private var apiService = TLAPIService()
    private var openAIAPIService = OpenAIAPIService()
    private var cancellable: AnyCancellable?
    private var alertMessage: String?
    @Published var loadingMessage: String? = nil
    //@Published var backgroundLocationImageUrl: String?
    //@Published var randomLocationCity: String?
    @Published var placeImageChanged: Bool = false

    var places = [Location]()
    var savedPlaces = [Location]()
    
    func parseCityAndCountry(from address: String, completion: @escaping (String?, String?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, nil, error)
                return
            }
            
            let city = placemark.locality
            let country = placemark.country
            
            completion(city, country, nil)
        }
    }
    
    func searchLocation(with keyword: String) {
        self.loadingMessage = "Searching locations for \(keyword)"
        self.placeImageChanged = false

        self.cancellable = self.apiService.searchLocation(keyword: keyword)
        .catch {_ in Just([Location]()) }
        .sink(receiveCompletion: { _ in }, receiveValue: {
            self.places = $0
            self.placeImageChanged = true
            //self.generateBannerFromAddress(place: self.places.first)
            self.loadingMessage = nil
        })
    }
    
    func reloadIcon(destination: Destination) {
        self.searchLocation(with: destination.name.searchSanitized() + "+city")
    }
//    
//    func fetchRandomLocationPhoto(keyword: String) {
//        self.randomLocationCity = nil
//        self.cancellable = self.openAIAPIService.openAPIGenerateImage(keyword: keyword)
//        .catch {_ in Just(ChatGPTImageResponse(created: 0, data: [])) }
//        .sink(receiveCompletion: { _ in }, receiveValue: {
//            self.randomLocationCity = keyword
//            self.backgroundLocationImageUrl = $0.data.first?.url
//        })
//    }
    
    func populateAnotations() {
        for place in self.places.uniqued(by: \.place_id) {
            let anotation = AnotationItem(
                id: place.id,
                userid: 1,
                name: place.name,
                coordinate: CLLocationCoordinate2D(
                    latitude: place.lat,
                    longitude: place.lng),
                remoteIcon: place.icon,
                place: place
            )
            
            self.annotations.append(anotation)
        }
        
        self.spinner = false
    }
    
    func fetchPlaces(with keyword: String) {
        self.spinner = true
        
        self.cancellable = self.apiService.searchLocation(keyword: keyword)
        .catch {_ in Just([Location]()) }
        .sink(receiveCompletion: { _ in }, receiveValue: {
            self.places = $0
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: self.places.first?.lat ?? 43.6582232,
                    longitude: self.places.first?.lng ?? -79.36996829999998),
                span: MKCoordinateSpan(
                    latitudeDelta: 1.5,
                    longitudeDelta: 1.5)
            )

            self.populateAnotations()
        })
    }
}
