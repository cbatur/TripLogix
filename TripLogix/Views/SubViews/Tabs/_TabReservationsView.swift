
import SwiftUI
import Popovers

struct _TabReservationsView: View {
    @Bindable var destination: Destination
    @State private var displayBottomToolbar = true
    @State private var flightManageViewDisplay = false
    @State private var deleteFlight = false
    @State private var flightToDelete: DSelectedFlight?
    @State var flightTypesButtonDisabled = true
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
            Form {
                ForEach(destination.flights, id: \.self) { f in
                    Section(header: Text("\(formatDateDisplay(f.date))")) {
                        D_FlightResultCard(f)
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
            
            VStack {
                VStack {
                    if self.displayBottomToolbar == false {
    
                        Text("MANAGE RESERVATIONS")
                            .font(.custom("Gilroy-Meduim", size: 20))
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, alignment: .center)
                        .onTapGesture {
                            self.displayBottomToolbar = true
                        }
                        .animation(.easeInOut(duration: 0.3), value: displayBottomToolbar)
    
                    } else {
    
                        VStack {
                            Button(action: {
                                self.displayBottomToolbar = false
                            }) {
                                HStack {
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom, 10)
                            }
    
                            HStack {
                                Templates.Menu {
                                    Templates.MenuButton(title: "Add Manually", systemImage: "rectangle.and.text.magnifyingglass") {
                                        flightManageViewDisplay = true
                                    }
                                    Templates.MenuButton(title: "Add From Image", systemImage: "photo") {
                                        launchImageToFlightView = true
                                    }
                                    Templates.MenuButton(title: "Email Reservation", systemImage: "at") { }
                                    .disabled(flightTypesButtonDisabled)
                                    
                                } label: { fade in
                                    VStack {
                                        Text("FLIGHTS")
                                            .font(.custom("Satoshi-Bold", size: 15))
                                            .padding(10)
                                            .foregroundColor(.white)
                                            .cornerRadius(5)
                                            .cardStyle(.black.opacity(0.5))
                                    }
                                    .opacity(fade ? 0.5 : 1)
                                }
                                
                                Button {
                                    //Manage Hotels
                                } label: {
                                    Text("HOTELS")
                                        .font(.custom("Satoshi-Bold", size: 15))
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                        .cardStyle(.black.opacity(0.5))
                                }
                                
                                Button {
                                    //Manage Car Rentals
                                } label: {
                                    Text("CAR RENTALS")
                                        .font(.custom("Satoshi-Bold", size: 15))
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                        .cardStyle(.black.opacity(0.5))
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: displayBottomToolbar)
                        .padding()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, alignment: .center)
                .padding()
                .cardStyle(.black.opacity(0.5))
            }
        }
        .sheet(isPresented: $flightManageViewDisplay) {
            FlightManageView(destination: destination)
        }
        .sheet(isPresented: $launchImageToFlightView) {
            ImageToFlightView(actionPassFlights: passSelectedFlights)
        }
        .onChange(of: self.flightToDelete) { _, flight in
            guard let _ = flight else { return }
            self.deleteFlight = true
        }
        .customActionSheet(isPresented: $deleteFlight) {
            if let f = flightToDelete {
                VStack {
                    Text("Delete This Flight?")
                    Divider()
                    D_FlightResultCard(f)
                    Divider()
                    HStack {
                        Button {
                            deleteFlight(f)
                        } label: {
                            Text("YES, DELETE")
                                .padding()
                                .cardStyle(.wbPinkMedium)
                        }
                        
                        Button {
                            deleteFlight = false
                            self.flightToDelete = nil
                        } label: {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}

