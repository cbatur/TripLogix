import Foundation
import Combine

enum AirportSearchMode {
    case departure
    case arrival
}

@MainActor
final class AirportsViewModel: ObservableObject {
    private let flightServices: FlightServices
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var searchQuery: String = ""
    @Published private(set) var suggestions: [Airport] = []
    @Published var selectedAirport: Airport?
    
    // For airport caching - To be implemented later
    @Published var airports: [Airport] = []
    @Published var cachedSSAirports: [Airport.AirportPresentation] = []
    @Published var fromAirport: Airport.AirportPresentation?
    @Published var toAirport: Airport.AirportPresentation?

    private var cancellables = Set<AnyCancellable>()
    private let mode: AirportSearchMode
    
    init(mode: AirportSearchMode, flightServices: FlightServices = FlightServices()) {
        self.flightServices = flightServices
        self.mode = mode
        setupSearchListener()
    }

    private func setupSearchListener() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [weak self] queryString -> AnyPublisher<[Airport], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                
                if queryString.count < 3 {
                    self.isLoading = false
                    return Just([]).eraseToAnyPublisher()
                }
                
                self.isLoading = true
                
                return Future { promise in
                    Task {
                        do {
                            let airports = try await self.flightServices.searchAirports(city: queryString)
                            await MainActor.run {
                                promise(.success(airports.data))
                            }
                        } catch {
                            await MainActor.run {
                                self.errorMessage = error.localizedDescription
                                promise(.success([]))
                            }
                        }
                        self.isLoading = false
                    }
                }
                .eraseToAnyPublisher()
            }
            .assign(to: &$suggestions)
    }

    func selectAirport(_ suggestion: Airport) {
        DispatchQueue.main.async {
            self.selectedAirport = suggestion
            self.searchQuery = suggestion.presentation.suggestionTitle
            self.suggestions = []
        }
    }
    
    func resetSearch() {
        DispatchQueue.main.async {
            self.searchQuery = ""
            self.selectedAirport = nil
            self.suggestions = []
        }
    }
}

// Airport Cache Management
extension AirportsViewModel {
    
    func cacheAirports() {
        for a in self.airports {
            manageSSAirporteCache(a.presentation)
        }
    }
    
    func pullAirportFromCache(_ destination: Destination) {
        getCachedSSAirports()
        
        fromAirport = cachedSSAirports.first(where: { $0.suggestionTitle.contains("Toronto") })
        toAirport = cachedSSAirports.first(where: { $0.suggestionTitle.contains(destination.name.components(separatedBy: ",").first ?? "-*-") })
    }
    
    func getCachedSSAirports() {
        self.cachedSSAirports = []
        if let savedObjects = UserDefaults.standard.object(forKey: "savedSSAirports") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([Airport.AirportPresentation].self, from: savedObjects) {
                self.cachedSSAirports = loadedObjects
                removeOlderCachedAirports()
            }
        }
    }
    
    func removeOlderCachedAirports() {
        // Keeps the last 300 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedSSAirports.prefix(300))) {
            UserDefaults.standard.set(encoded, forKey: "savedSSAirports")
        }
    }
    
    // Cache Sky Scrapper Airports
    func manageSSAirporteCache(_ p: Airport.AirportPresentation) {
        getCachedSSAirports()
        
        if !self.cachedSSAirports.contains(where: { $0.id == p.id }) {
            self.cachedSSAirports.append(p)
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.cachedSSAirports) {
            UserDefaults.standard.set(encoded, forKey: "savedSSAirports")
        }
    }
}
