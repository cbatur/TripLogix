import Foundation
import Combine

final class AviationEdgeViewmodel: ObservableObject {

    @Published var loading: Bool = false
    @Published var futureFlights = [AEFutureFlight]()
    @Published var searchPerformed = false
    @Published var cachedFlights = [FlightChecklist]()

    private var apiService = AviationEdgeAPIService()
    private var cancellable: AnyCancellable?
    
    func getFutureFlights(
        _ futureFlightParams: AEFutureFlightParams,
        flightChecklist: FlightChecklist
    ) {
        let filterAirportCode = flightChecklist.arrivalCity?.codeIataCity ?? ""
        searchPerformed = true
        loading = true
        self.cancellable = self.apiService.futureFlights(futureFlightParams: futureFlightParams)
        .catch {_ in Just([]) }
        .sink(receiveCompletion: { _ in }, receiveValue: {
            self.loading = false
            self.migrateFutureFlights($0.filter({ flight in
                flight.arrival.iataCode == filterAirportCode.lowercased() &&
                !flight.airline.name.isEmpty
            }), flightChecklist: flightChecklist)
        })
    }
    
    func removeOlderRecords() {
        // Keeps the last 7 records, removes the older ones.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Array(self.cachedFlights.prefix(6))) {
            UserDefaults.standard.set(encoded, forKey: "cachedFlights")
        }
    }
    
    func getCachedFlightsSearch() {
        if let savedObjects = UserDefaults.standard.object(forKey: "cachedFlights") as? Data {
            let decoder = JSONDecoder()
            if let loadedObjects = try? decoder.decode([FlightChecklist].self, from: savedObjects) {
                self.cachedFlights = loadedObjects.reversed()
                removeOlderRecords()
            } else { return }
        } else { return }
    }
    
    func setFlightChecklist(_ f: FlightChecklist) {
        getCachedFlightsSearch()
        //var flightChecklist = getCachedFlightsSearch()
        
        if !self.cachedFlights.contains(where: {
            $0.flightDate == f.flightDate &&
            $0.arrivalCity?.codeIataAirport == f.arrivalCity?.codeIataAirport &&
            $0.departureCity?.codeIataAirport == f.departureCity?.codeIataAirport
        }) {
            self.cachedFlights.append(f)
        }

        //cachedFlights = flightChecklist
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.cachedFlights) {
            UserDefaults.standard.set(encoded, forKey: "cachedFlights")
        }
    }
    
    func migrateFutureFlights(
        _ flights: [AEFutureFlight],
        flightChecklist: FlightChecklist
    ) {
        self.futureFlights = flights
        if flights.count > 0 {
            setFlightChecklist(flightChecklist)
        }
    }
    
    func resetSearchFlights() {
        futureFlights = []
    }
    
    func deActivateSearch() {
        searchPerformed = false
        futureFlights = []
    }
    
    func clearCachedFlightSearches() {
        UserDefaults.standard.removeObject(forKey: "cachedFlights")
        cachedFlights = []
    }
}
