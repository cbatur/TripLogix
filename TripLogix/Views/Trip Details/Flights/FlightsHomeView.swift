
import SwiftUI
import Popovers

struct FlightsHomeView: View {
    @Bindable var destination: Destination
    @StateObject var viewModel: SSFlightsViewModel = SSFlightsViewModel()

    @State private var displayBottomToolbar = true
    @State private var flightManageViewDisplay = false
    @State private var deleteFlight = false
    @State private var flightToDelete: DSelectedFlight?
    @State var launchImageToFlightView = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func deleteFlight(_ flight: DSelectedFlight) {
        destination.flights.removeAll { $0.id == flight.id }
        deleteFlight = false
    }
    
    // Move Public FlightMethods to here
    public func convertFlight(_ s: SelectedFlight) -> DSelectedFlight {
        let dDeparture = DAirportDetail(
            iataCode: s.flight.departure.iataCode,
            icaoCode: s.flight.departure.icaoCode,
            terminal: s.flight.departure.terminal,
            gate: s.flight.departure.gate,
            scheduledTime: s.flight.departure.scheduledTime
        )
        
        let dArrival = DAirportDetail(
            iataCode: s.flight.arrival.iataCode,
            icaoCode: s.flight.arrival.icaoCode,
            terminal: s.flight.arrival.terminal,
            gate: s.flight.arrival.gate,
            scheduledTime: s.flight.arrival.scheduledTime
        )
        
        let dAircraft = DAircraft(
            modelCode: s.flight.aircraft.modelCode,
            modelText: s.flight.aircraft.modelText
        )
        
        let dAirline = DAirline(
            name: s.flight.airline.name,
            iataCode: s.flight.airline.iataCode,
            icaoCode: s.flight.airline.icaoCode
        )
        
        let dFlight = DFlight(
            number: s.flight.flight.number,
            iataNumber: s.flight.flight.iataNumber,
            icaoNumber: s.flight.flight.icaoNumber
        )
        
        let dFutureFlight = DFutureFlight(
            weekday: s.flight.weekday,
            departure: dDeparture,
            arrival: dArrival,
            aircraft: dAircraft,
            airline: dAirline,
            flight: dFlight
        )
        
        let dSelectedFlight = DSelectedFlight(
            date: s.date,
            flight: dFutureFlight
        )

        return dSelectedFlight
    }
    
    func passSelectedFlights(_ selectedFlights: [SelectedFlight]) {
        for s in selectedFlights {
            if !destination.flights.contains(convertFlight(s)) {
                destination.flights.append(convertFlight(s))
                
                AnalyticsManager.shared.logEvent(
                    name: "_TabReservationsView_AddFlight",
                    params: ["added_flight": simplfyFlightInfo(s)]
                )
            }
        }
    }
    
    private func simplfyFlightInfo(_ f: SelectedFlight) -> String {
        return "\(f.flight.departure.iataCode.uppercased()) ➔ \(f.flight.arrival.iataCode.uppercased()) - \(f.flight.airline.iataCode.uppercased()) \(f.flight.flight.number)\n"
    }
    
    var body: some View {
        VStack {
            popUpMenu
            
            Form {
                ForEach(destination.flights, id: \.self) { f in
                    Section(header: Text("\(formatDateDisplay(f.date))")) {
                        //D_FlightResultCard(f)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Jakarta")
                                Text("CGK")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("12:30")
                            }
                            Spacer()
                            VStack {
                                Text("1 Jan 2024")
                                Image(systemName: "airplane")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                Text("21h 45min")
                                    .padding(.horizontal)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Singapore")
                                Text("SIN")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("13:45")
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding()
                    }
                    .onTapGesture {
                        flightToDelete = f
                        deleteFlight = true
                    }
                }
            }
            .opacity(0.8)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .frame(maxWidth: .infinity)
            .isHidden(destination.flights.count == 0)
            
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
        .onChange(of: self.flightToDelete) { _, flight in
            guard let _ = flight else { return }
            self.deleteFlight = true
        }
//        .customActionSheet(isPresented: $deleteFlight) {
//            if let f = flightToDelete {
//                VStack {
//                    Text("Delete This Flight?")
//                    Divider()
//                    D_FlightResultCard(f)
//                    Divider()
//                    HStack {
//                        Button {
//                            deleteFlight(f)
//                        } label: {
//                            Text("YES, DELETE")
//                                .padding()
//                                .cardStyle(.wbPinkMedium)
//                        }
//                        
//                        Button {
//                            deleteFlight = false
//                            self.flightToDelete = nil
//                        } label: {
//                            Image(systemName: "xmark.circle")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 23, height: 23)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//            }
//        }
    }
    
    private var popUpMenu: some View {
        VStack {
            HStack {
                HeaderView(title: "Flights")
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

