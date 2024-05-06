import Combine
import Foundation

final class SSFlightsViewModel: ObservableObject {
    
    @Published var query = ""
    @Published var airports: [SSAirport] = []
    @Published var itineraries: [SSItinerary] = []
    @Published var cachedSSAirports: [SSAirport.SSAirportPresentation] = []
    @Published var globalSSAirports: [SSAirport] = []
    @Published var searchModeOn: Bool = false
    @Published var searchLoading: Bool = false

    @Published var fromAirport: SSAirport.SSAirportPresentation?
    @Published var toAirport: SSAirport.SSAirportPresentation?

    @Published var activeAlertBox: AlertBoxMessage?
    
    private let apiHost = Configuration.SkyScrapper.apiHost
    
    private var cancellableSet: Set<AnyCancellable> = []
    private let ssAPIService = SkyScrapperAPIService()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Adds a debounce to limit requests
            .removeDuplicates() // Avoids sending a request if the search text hasn't changed
            .filter { $0.count > 2 } // Only sends a request if the search text has more than 2 characters
            .flatMap { query in
                self.fetchAirportsPublisher(query: query)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { [weak self] airports in
                self?.globalSSAirports = airports.data
            })
            .store(in: &cancellableSet)
    }
    
    private func fetchAirportsPublisher(query: String) -> AnyPublisher<SSAirportResponse, Error> {
        guard let url = URL(string: "https://\(Configuration.SkyScrapper.apiHost)/flights/auto-complete?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        guard let apiKey = decryptAPIKey(.skyScrapper) else { preconditionFailure("Bad API Key") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(apiHost, forHTTPHeaderField: "X-RapidAPI-Host")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SSAirportResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchAirport(_ city: String) -> AnyPublisher<[SSAirport], SSError> {
        guard city.count == 3 else {
            return Just([]).setFailureType(to: SSError.self).eraseToAnyPublisher()
        }

        return ssAPIService.airportSearch(city: city)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
    
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
