import Foundation

@MainActor
final class FlightsViewModel: ObservableObject {
    private let flightService: FlightAPIService
    @Published var errorMessage: String?
    @Published var isFlightSearchLoading: Bool = false
    @Published var flightResults: [SSItinerary] = []
    
    init(flightService: FlightAPIService = FlightAPIService()) {
        self.flightService = flightService
    }
}

extension FlightsViewModel {
    
    /// Fetch flights from API
    func searchFlights(date: String, origin: String, destination: String) async {
        await MainActor.run {
            isFlightSearchLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isFlightSearchLoading = false
            }
        }
        
        do {
            let flightsResponse = try await flightService.flightSearch(date: date, d: origin, a: destination)
            
            await MainActor.run {
                self.flightResults = flightsResponse //flightsResponse.data.itineraries
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// Mock Services
extension FlightsViewModel {
    func searchFlightsMock() {
        if let fileURL = Bundle.main.url(forResource: "SS_FlightSearchResults", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let items = try JSONDecoder().decode(FlightResponse.self, from: data)
                self.flightResults = items.data.itineraries
            } catch {
                print("Error reading or parsing city.JSON: \(error.localizedDescription)")
            }
        } else {
            print("JSON file not found.")
        }
    }
}
    
extension FlightsViewModel {

    // MARK: - Flight Conversion (SSLeg -> DSSLeg)
    func convertFlight(_ s: Leg) -> DSSLeg {
        var dMarketing: [DSSMarketing] = []
        for m in s.carriers.marketing {
            dMarketing.append(
                DSSMarketing(
                    logoUrl: m.logoUrl,
                    name: m.name
                )
            )
        }
        
        let dCarrier = DCarrier(
            marketing: dMarketing,
            operationType: s.carriers.operationType
        )
        
        let dOriginAirportEntity = DSSAirportEntity(
            id: s.origin.id,
            entityId: s.origin.entityId,
            name: s.origin.name,
            displayCode: s.origin.displayCode,
            city: s.origin.city,
            country: s.origin.country
        )
        
        let dDestinationAirportEntity = DSSAirportEntity(
            id: s.destination.id,
            entityId: s.destination.entityId,
            name: s.destination.name,
            displayCode: s.destination.displayCode,
            city: s.destination.city,
            country: s.destination.country
        )
        
        var dSelectedSegments: [DSSSegment] = []
        for segment in s.segments {
            
            let dOriginRouteParent = DSSRouteParent(
                flightPlaceId: segment.origin.parent.flightPlaceId,
                displayCode: segment.origin.parent.displayCode,
                name: segment.origin.parent.name,
                type: segment.origin.parent.type
            )
            
            let dOriginRoute = DSSRoute(
                flightPlaceId: segment.origin.flightPlaceId,
                name: segment.origin.name,
                type: segment.origin.type,
                country: segment.origin.country,
                parent: dOriginRouteParent
            )
            
            let dDestinationRouteParent = DSSRouteParent(
                flightPlaceId: segment.destination.parent.flightPlaceId,
                displayCode: segment.destination.parent.displayCode,
                name: segment.destination.parent.name,
                type: segment.destination.parent.type
            )
            
            let dDestinationRoute = DSSRoute(
                flightPlaceId: segment.destination.flightPlaceId,
                name: segment.destination.name,
                type: segment.destination.type,
                country: segment.destination.country,
                parent: dDestinationRouteParent
            )
            
            let dMarketingCarier = DSSCarrier(
                name: segment.marketingCarrier.name,
                alternateId: segment.marketingCarrier.alternateId
            )

            dSelectedSegments.append(
                DSSSegment(
                    id: segment.id,
                    origin: dOriginRoute,
                    destination: dDestinationRoute,
                    departure: segment.departure,
                    arrival: segment.arrival,
                    durationInMinutes: segment.durationInMinutes,
                    flightNumber: segment.flightNumber,
                    marketingCarrier: dMarketingCarier
                )
            )
        }

        let dLeg = DSSLeg(
            id: s.id,
            origin: dOriginAirportEntity,
            destination: dDestinationAirportEntity,
            durationInMinutes: s.durationInMinutes,
            flightNumber: s.flightNumber,
            stopCount: s.stopCount,
            departure: s.departure,
            arrival: s.arrival,
            timeDeltaInDays: s.timeDeltaInDays,
            carriers: dCarrier,
            segments: dSelectedSegments
        )

        return dLeg
    }
}
