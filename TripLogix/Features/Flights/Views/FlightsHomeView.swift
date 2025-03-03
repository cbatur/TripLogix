import SwiftUI

struct FlightsHomeView: View {
    @Bindable var destination: Destination
    @StateObject var departureViewModel = AirportsViewModel(mode: .departure)
    @StateObject var arrivalViewModel = AirportsViewModel(mode: .arrival)
    @ObservedObject var viewModel = FlightsViewModel()
    @State private var selectedDate: Date = Date()
    @State private var showSearchForm: Bool = false
    @State private var showDeletionAlert: Bool = false
    @State private var flightToDeleteID: String? = nil
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func sortFlightsByDate(_ segments: [DSSLeg]) -> [DSSLeg] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let sortedSegments = segments.sorted { (lhs, rhs) -> Bool in
            if let lhsDate = formatter.date(from: lhs.departure), let rhsDate = formatter.date(from: rhs.departure) {
                return lhsDate < rhsDate
            }
            return false
        }
        return sortedSegments
    }
    
    func addFlightToTrip(_ flight: Leg) {
        let s = viewModel.convertFlight(flight)
        
        if !destination.flightLegs.contains(where: { $0.id == s.id }) {
            withAnimation {
                destination.flightLegs.append(s)
            }
        }
    }
    
    private func removeFlight(flightID: String) {
        withAnimation {
            if let index = destination.flightLegs.firstIndex(where: { $0.id == flightID }) {
                destination.flightLegs.remove(at: index)
            }
        }
    }

    var body: some View {
        VStack {
            if showSearchForm {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .onTapGesture {
                                showSearchForm = false
                            }
                        Spacer()
                    }
                    
                    FlightSearchView(
                        departureViewModel: departureViewModel,
                        arrivalViewModel: arrivalViewModel,
                        selectedDate: $selectedDate, passSelectedFlight: addFlightToTrip
                    )
                    .padding()
                    .cardStyle(.white)
                    .padding()
                }
                .padding(.top, 20)
            }
                        
            VStack {
                if destination.flightLegs.isEmpty {
                    emptyStateView
                        .isHidden(showSearchForm)
                } else {
                    HStack {
                        Text("Your Added Flights")
                            .font(.system(size: 20)).bold()
                            .foregroundColor(.black)
                        Spacer()
                        if !showSearchForm {
                            Button {
                                showSearchForm = true
                            } label: {
                                Label("Add Flight", systemImage: "plus.circle")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .cornerRadius(24)
                                    .foregroundColor(Color.slSofiColor)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    
                    VStack {
                        ForEach(sortFlightsByDate(destination.flightLegs), id: \.self) { flight in
                            AddedFlightCardView(
                                id: flight.id,
                                airlineName: "\(flight.carriers.marketing[0].name) \(flight.segments[0].flightNumber)",
                                flightNumber: formatDateFlightCard(from: flight.departure),
                                airlineImageName: flight.carriers.marketing[0].logoUrl,
                                departureTime: extractTime(from: flight.departure),
                                departureAirport: flight.origin.displayCode,
                                duration: formatMinutes(flight.durationInMinutes),
                                arrivalTime: extractTime(from: flight.arrival),
                                arrivalAirport: flight.destination.displayCode,
                                arrivalAirportName: flight.destination.name,
                                departureAirportName: flight.origin.name,
                                onDelete: { flightID in
                                    flightToDeleteID = flightID
                                    showDeletionAlert = true
                                }
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut, value: destination.flightLegs)
                    .padding()
                }
            }
        }
        .onChange(of: destination.flightLegs) { _, _ in
            showSearchForm = destination.flightLegs.count == 0
        }
        .alert("Delete selected flight?",
           isPresented: $showDeletionAlert,
           actions: {
               Button("Delete", role: .destructive) {
                   if let flightID = flightToDeleteID {
                       removeFlight(flightID: flightID)
                   }
               }
               Button("Cancel", role: .cancel) {}
           },
           message: {
               Text("Are you sure you want to remove this flight from your itinerary?")
           }
        )
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.slSofiColor.opacity(0.1))
                    .frame(width: 96, height: 96)
                Image(systemName: "airplane.departure")
                    .font(.system(size: 44))  // ~ text-4xl
                    .foregroundColor(.slSofiColor)
            }
            .padding(.top, 40)

            Text("No Flights Added")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Start searching for flights to add them to your trip")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                showSearchForm = true
            }) {
                Text("Search Flights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.slSofiColor)
                    .cornerRadius(8)
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 40)
    }
}
