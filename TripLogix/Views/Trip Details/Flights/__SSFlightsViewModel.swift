import Combine
import Foundation

final class SSFlightsViewModel: ObservableObject {
    
    @Published var airports: [SSAirport] = []
    @Published var itineraries: [SSItinerary] = []
    @Published var cachedSSAirports: [SSAirport.SSAirportPresentation] = []
    @Published var searchModeOn: Bool = false
    @Published var searchLoading: Bool = false

    @Published var fromAirport: SSAirport.SSAirportPresentation?
    @Published var toAirport: SSAirport.SSAirportPresentation?

    @Published var activeAlertBox: AlertBoxMessage?
    
    private let apiHost = Configuration.SkyScrapper.apiHost
    
    private var cancellableSet: Set<AnyCancellable> = []
    private let ssAPIService = SkyScrapperAPIService()
    
    // Make an API Call to a single airport and cache
    func queryAirport(_ city: String) {
        ssAPIService.airportSearch(city: city)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.activeAlertBox = AlertBoxMessage.error("Something Went Wrong! Please try again.")
                }
            }, receiveValue: { response in
                self.airports = response.data
                self.cacheAirports()
            })
            .store(in: &cancellableSet)
    }
    
    func searchFlights(_ date: String, d: String, a: String) {
        searchModeOn = true
        searchLoading = true
        ssAPIService.flightSearch(date: date, d:d, a:a)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.activeAlertBox = AlertBoxMessage.error("Something Went Wrong! Please try again.")
                }
            }, receiveValue: { response in
                self.searchLoading = false
                self.itineraries = response.data.itineraries
            })
            .store(in: &cancellableSet)
    }
    
    func pullAirportFromCache(_ destination: Destination) {
        getCachedSSAirports()
        
        fromAirport = cachedSSAirports.filter({ airport in
            airport.suggestionTitle.contains("Toronto")
        }).first

        toAirport = cachedSSAirports.filter({ airport in
            airport.suggestionTitle.contains(destination.name.components(separatedBy: ",").first ?? "-*-")
        }).first
    }
    
}

// Airport Cache Management
extension SSFlightsViewModel {
    
    func cacheAirports() {
        for a in self.airports {
            manageSSAirporteCache(a.presentation)
        }
    }
    
    func getCachedSSAirports() {
        self.cachedSSAirports = []
        if let savedObjects = UserDefaults.standard.object(forKey: "savedSSAirports") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([SSAirport.SSAirportPresentation].self, from: savedObjects) {
                self.cachedSSAirports = loadedObjects
                removeOlderCachedAirports()
            } else { return }
        } else { return }
    }
    
    func removeOlderCachedAirports() {
        // Keeps the last 300 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedSSAirports.prefix(300))) {
            UserDefaults.standard.set(encoded, forKey: "savedSSAirports")
        }
    }
    
    // Cache Sky Scrapper Airports
    func manageSSAirporteCache(_ p: SSAirport.SSAirportPresentation) {
        getCachedSSAirports()
        
        if !self.cachedSSAirports.contains(where: {
            $0.id == p.id
        }) {
            self.cachedSSAirports.append(p)
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.cachedSSAirports) {
            UserDefaults.standard.set(encoded, forKey: "savedSSAirports")
        }
    }
}

// Mock Services
extension SSFlightsViewModel {
    func searchFlightsMock() {
        if let fileURL = Bundle.main.url(forResource: "SS_FlightSearchResults", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let items = try JSONDecoder().decode(SSFlightResponse.self, from: data)
                self.itineraries = items.data.itineraries
            } catch {
                print("Error reading or parsing city.JSON: \(error.localizedDescription)")
            }
        } else {
            print("JSON file not found.")
        }
    }
}
