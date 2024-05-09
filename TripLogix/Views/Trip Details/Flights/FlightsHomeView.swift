
import SwiftUI
import Popovers

struct FlightsHomeView: View {
    @Bindable var destination: Destination
    @StateObject var viewModel: SSFlightsViewModel = SSFlightsViewModel()

    @State private var displayBottomToolbar = true
    @State private var flightManageViewDisplay = false
    @State private var deleteFlight = false
    @State private var flightToDelete: DSSLeg?
    @State var launchImageToFlightView = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func deleteFlight(_ flight: DSSLeg) {
        destination.flightLegs.removeAll { $0.id == flight.id }
        deleteFlight = false
    }
    
    // Process response received from Image Scan
    func passSelectedFlights(_ selectedFlights: [SelectedFlight]) {
        for s in selectedFlights {
//            if !destination.flights.contains(convertFlight(s)) {
//                destination.flights.append(convertFlight(s))
//                
//                AnalyticsManager.shared.logEvent(
//                    name: "_TabReservationsView_AddFlight",
//                    params: ["added_flight": simplfyFlightInfo(s)]
//                )
//            }
        }
    }
    
    private func simplfyFlightInfo(_ f: SelectedFlight) -> String {
        return "\(f.flight.departure.iataCode.uppercased()) ➔ \(f.flight.arrival.iataCode.uppercased()) - \(f.flight.airline.iataCode.uppercased()) \(f.flight.flight.number)\n"
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
    
    func sortSegmentsByDate(_ segments: [DSSSegment]) -> [DSSSegment] {
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
    
    var body: some View {
        VStack {
            popUpMenu
            
            Form {
                ForEach(sortFlightsByDate(destination.flightLegs), id: \.self) { leg in
                    Section(header:
                        VStack {
                            HStack {
                                AsyncImage(url: URL(string: "\(leg.carriers.marketing.first?.logoUrl ?? "")")) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 25, height: 25)
                                
                                Text("\(leg.carriers.marketing.first?.name ?? "")")
                                    .font(.subheadline)
                                
                                Text(leg.stopCount > 0 ? "Stops: \(leg.stopCount)" : "")
                                    .foregroundColor(.tlOrange).bold()
                                
                                Spacer()
                                Image(systemName: "trash")
                                    .font(.headline )
                                    .onTapGesture {
                                        flightToDelete = nil
                                        flightToDelete = leg
                                        deleteFlight = true
                                    }
                            }
                        }
                    ) {
                        ForEach(sortSegmentsByDate(leg.segments), id: \.self) { segment in
                            DSSSegmentCard(segment: segment)
                        }
                    }
                }
            }
            .opacity(0.8)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .frame(maxWidth: .infinity)
            .isHidden(destination.flightLegs.count == 0)
            
            Spacer()
            buttonsToolBar
            
        }
        .onAppear {
            flightManageViewDisplay = true
            viewModel.queryAirport(destination.name.components(separatedBy: ",").first ?? "London")
        }
        .sheet(isPresented: $flightManageViewDisplay) {
            SS_ManualFlightSearchView(destination: destination)
        }
        .sheet(isPresented: $launchImageToFlightView) {
            ImageToFlightView(actionPassFlights: passSelectedFlights)
        }
        .customAlert(isVisible: $deleteFlight,
                     content: {
            
            DeleteFlightAlert(
                showAlert: $deleteFlight,
                leg: flightToDelete,
                actionSelectedLeg: deleteFlight
            )
            .padding()
        })
    }
    
    private var popUpMenu: some View {
        VStack {
            HStack {
                HeaderView(title: "Flights in my trip")
                Spacer()
                Templates.Menu {
                    Templates.MenuButton(title: "Add Manually", systemImage: "rectangle.and.text.magnifyingglass") {
                        flightManageViewDisplay = true
                    }
                    Templates.MenuButton(title: "Add From Image", systemImage: "photo") {
                        launchImageToFlightView = true
                    }
                    Templates.MenuButton(title: "Email Reservation", systemImage: "at") { }
                    //.disabled(flightTypesButtonDisabled)
                    
                } label: { fader in
                    Image(systemName: "plus")
                        .aspectRatio(contentMode: .fit)
                        .font(.system(size: 21)).bold()
                        .background(.clear)
                        .padding(8)
                        .buttonStylePrimary(.green)
                        .padding(.trailing, 10)
                        .opacity(fader ? 0.5 : 1)
                }

                .padding(.trailing, 10)
            }
        }
    }
    
    private var buttonsToolBar: some View {
        HStack {
            buttonAddManually
            buttonFromImage
        }
        .padding(.top, 20)
        .isHidden(viewModel.activeAlertBox != nil)
    }
    
    private var buttonAddManually: some View {
//        Button(action: { flightManageViewDisplay = true }) {
//
//        }
        Label("Add Manually", systemImage: "text.redaction")
        .padding(.horizontal, 15)
        .padding(9)
        .buttonStylePrimary(.pink)
        .onTapGesture {
            flightManageViewDisplay = true
        }
        
    }

    private var buttonFromImage: some View {
        Button(action: { launchImageToFlightView = true }) {
            Label("Add From Image", systemImage: "text.redaction")
            .padding(.horizontal, 15)
            .padding(9)
        }
        .buttonStylePrimary(.primary)
    }
}

