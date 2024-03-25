
import SwiftUI
import Popovers

struct FlightManageView: View {
    @Environment(\.presentationMode) var presentationMode
    @Bindable var destination: Destination
    @StateObject var aviationEdgeViewmodel: AviationEdgeViewmodel = AviationEdgeViewmodel()
    @State private var flightDate = Date()

    @State private var launchSearchAirport: Bool = false
    @State private var launchSearchResultsView: Bool = false
        
    @State private var departureCity: AEAirport.AECity?
    @State private var arrivalCity: AEAirport.AECity?
    @State private var airportType: AirportType = .departure
    
    @State private var showDatePicker: Bool = false
    @State private var isClearCacheVerified: Bool = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BannerWithDismiss(
                    dismiss: dismiss,
                    headline: "Add Flights to Trip".uppercased(),
                    subHeadline: "Search for a one-way flight"
                )
                .padding()
                .padding(.top, 10)
                
                VStack {
                    VStack {
                        VStack {
                            if showDatePicker {
                                DatePicker(flightDate <= Date() ? "SELECT A FUTURE DATE" : "✔", selection: $flightDate, in: Date()..., displayedComponents: .date)
                                    .onChange(of: flightDate) { _, selectedDate in
                                        self.showDatePicker = false
                                        self.flightDate = selectedDate
                                    }
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .font(.custom("Satoshi-Bold", size: flightDate <= Date() ? 13 : 23))
                                    .padding(.leading, 15)
                                    .foregroundColor(flightDate <= Date() ? .red : .green)
                                    .background(Color.white)
                                    .cornerRadius(9)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.showDatePicker = true
                                        }
                                    }
                                
                            } else {
                                
                                Button(action: {
                                    self.showDatePicker.toggle()
                                }) {
                                    DatePicker(flightDate <= Date() ? "SELECT A FUTURE DATE" : "", selection: $flightDate, in: Date()..., displayedComponents: .date)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                self.showDatePicker = true
                                            }
                                        }
                                }
                            }
                        }
                        
                        Divider()
                        HStack {
                            Button {
                                launchSearchAirport = true
                                airportType = .departure
                            } label: {
                                if let departureCity = departureCity {
                                    AirportCard(airport: departureCity)
                                } else {
                                    Image(systemName: "airplane.departure")
                                        .foregroundColor(.gray.opacity(0.4))
                                        .font(.largeTitle)
                                        .frame(width: 45)
                                    
                                    VStack {
                                        Text(departureStatus().0.uppercased())
                                            .font(.custom("Gilroy-Bold", size: 16))
                                            .foregroundColor(Color.black.opacity(0.7))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Button {
                                launchSearchAirport = true
                                airportType = .arrival
                            } label: {
                                if let arrivalCity = arrivalCity {
                                    AirportCard(airport: arrivalCity)
                                } else {
                                    Image(systemName: "airplane.arrival")
                                        .foregroundColor(.gray.opacity(0.4))
                                        .font(.largeTitle)
                                        .frame(width: 45)
                                    
                                    VStack {
                                        Text(arrivalStatus().0.uppercased())
                                            .font(.custom("Gilroy-Bold", size: 16))
                                            .foregroundColor(Color.black.opacity(0.7))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    Divider()
                    Button {
                        searchFutureFlights()
                    } label: {
                        Text("SEARCH")
                            .padding(5)
                            .padding(.leading, 6)
                            .padding(.trailing, 6)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(isNotReadyForSearch() ? .black : .white)
                            .cardStyle(.wbPinkMedium)
                    }
                    .disabled(isNotReadyForSearch())
                    .opacity(isNotReadyForSearch() ? 0.3 : 1.0)
                }
                .padding()
                .cardStyle(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            VStack {
                HStack {
                    if isClearCacheVerified {
                        HStack {
                            Button{
                                aviationEdgeViewmodel.clearCachedFlightSearches()
                                isClearCacheVerified = false
                            } label: {
                                Text("Clear Search History?".uppercased())
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .padding(.leading, 5)
                                    .padding(.trailing, 5)
                                    .cardStyle(.red)
                            }
                            
                            Button {
                                isClearCacheVerified = false
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23, height: 23)
                                    .foregroundColor(.gray)
                            }
                        }
                        .isHidden(aviationEdgeViewmodel.cachedFlights.count == 0)

                    } else {
                        
                        Text("Recent Searches".uppercased())
                            .font(.custom("Gilroy-Medium", size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                        
                        Text("Clear")
                            .font(.custom("Gilroy-Medium", size: 14))
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                isClearCacheVerified = true
                            }
                            .isHidden(aviationEdgeViewmodel.cachedFlights.count == 0)
                    }
                }
                
                Divider()

                VStack {
                    HStack {
                        Text("No recorded flight searches...")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .isHidden(!aviationEdgeViewmodel.cachedFlights.isEmpty)
                    
                    ForEach(aviationEdgeViewmodel.cachedFlights) { f in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(f.departureCity?.codeIataAirport ?? "") ➔ \(f.departureCity?.nameAirport ?? "")")
                                    .font(.caption)
                                Text("\(f.arrivalCity?.codeIataAirport ?? "") ➔ \(f.arrivalCity?.nameAirport ?? "")")
                                    .font(.caption)
                            }
                            Spacer()
                            Text("\(f.flightDate ?? Date(), style: .date)")
                                .font(.subheadline)
                        }
                        .onTapGesture {
                            setChecklist(f)
                        }
                        .padding(.bottom, 5)
                        Divider()
                    }
                }
            }
            .padding()
        }
        .onAppear{
            self.aviationEdgeViewmodel.getCachedFlightsSearch()
        }
        .onChange(of: launchSearchResultsView) { _, _ in
            aviationEdgeViewmodel.getCachedFlightsSearch()
        }
        .background(Color.gray.opacity(0.11))
        .opacity(launchSearchAirport ? 0.2 : 1.0)
        .sheet(isPresented: $launchSearchResultsView) {
            let futureFlightsParams = AEFutureFlightParams(
                iataCode: departureCity?.codeIataAirport ?? "",
                type: "departure",
                date: formatDateParameter(flightDate)
            )
            
            SelectFlightResultsView(
                flightCheckList: flightCheckList(),
                futureFlightsParams: futureFlightsParams,
                actionPassFlight: passSelectedFlight
            )
        }
        .popover(
            present: $launchSearchAirport,
            attributes: {
                $0.position = .relative(
                    popoverAnchors: [
                        .top,
                    ]
                )

                let animation = Animation.spring(
                    response: 0.6,
                    dampingFraction: 0.8,
                    blendDuration: 1
                )
                let transition = AnyTransition.move(edge: .bottom).combined(with: .opacity)

                $0.presentation.animation = animation
                $0.presentation.transition = transition
                $0.dismissal.mode = [.dragDown, .tapOutside]
            }
        ) {
            SearchAirportPopover(
                present: $launchSearchAirport,
                action: fetchedFromChild,
                airportType: airportType
            )
            .frame(maxWidth: 500, maxHeight: 700, alignment: .top)
        }
    }
}

extension FlightManageView {
    
    func convertFlights(_ s: SelectedFlight) {
        
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
        
        destination.flights.append(dSelectedFlight)
        dismiss()
    }
    
    func passSelectedFlight(_ selectedFlight: SelectedFlight) {
        convertFlights(selectedFlight)
    }
    
    func setChecklist(_ f: FlightChecklist) {
        self.departureCity = f.departureCity
        self.arrivalCity = f.arrivalCity
        self.flightDate = f.flightDate ?? Date()        
    }
    
    func searchFutureFlights() {
        launchSearchResultsView = true
    }
    
    func fetchedFromChild(
        fromChild passedAirport: AEAirport.AECity,
        airportType: AirportType
    ) {
        self.aviationEdgeViewmodel.deActivateSearch()
        
        if airportType == .arrival {
            arrivalCity = passedAirport
        } else {
            departureCity = passedAirport
        }
    }
    
    private func departureStatus() -> (String, Color, Color) {
        if let airport = departureCity {
            return (airport.nameAirport, .white, .wbPinkMediumAlt)
        } else {
            return ("Select Departure Airport", .gray, .gray.opacity(0.2))
        }
    }
    
    private func arrivalStatus() -> (String, Color, Color) {
        if let airport = arrivalCity {
            return (airport.nameAirport, .white, .wbPinkMediumAlt)
        } else {
            return ("Select Arrival Airport", .gray, .gray.opacity(0.2))
        }
    }
    
    private func flightCheckList() -> FlightChecklist {
        return FlightChecklist(
            departureCity: departureCity,
            arrivalCity: arrivalCity,
            flightDate: flightDate
        )
    }
    
    private func isNotReadyForSearch() -> Bool {
        return (
            arrivalCity == nil ||
            departureCity == nil ||
            flightDate <= Date()
        )
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SearchAirportPopover: View {
    @StateObject var viewModel: AvionEdgeAutocompleteViewModel = AvionEdgeAutocompleteViewModel()
    
    @FocusState private var isInputActive: Bool

    @Binding var present: Bool
    @State var selection: String?
    
    var action: (AEAirport.AECity, AirportType) -> Void
    var airportType: AirportType

    private func clearText() {
        viewModel.resetSearch()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 14) {
                HStack {
                    Image(systemName: airportType.icon)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(airportType.message)".uppercased())
                        .font(.custom("Gilroy-Medium", size: 18))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                    
                    Spacer()

                    Button {
                        present = false
                        selection = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 19))
                            .foregroundColor(.secondary)
                            .frame(width: 38, height: 38)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(19)
                    }
                }
                
                TextField(airportType.placeholder, text: $viewModel.query)
                    .focused($isInputActive)
                    .font(.subheadline)
                    .padding()
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .cornerRadius(9)
                    .overlay(
                        HStack {
                            Spacer()
                            if !viewModel.query.isEmpty {
                                Button(action: clearText) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.headline)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                    )
            }
            .padding(24)
            
            VStack {
                ForEach(viewModel.suggestions.prefix(6), id: \.self) { airport in
                    AirportCard(airport: airport)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                action(airport, airportType)
                                present = false
                                selection = nil
                            }
                        }
                }
            }
            .padding()
        }
        .background(Color.gray7)
        .cornerRadius(16)
        .popoverShadow(shadow: .system)
        .onTapGesture {
            withAnimation(.spring()) {
                selection = nil
            }
        }
    }
}

struct SelectedFlight {
    var date: Date = Date()
    let flight: AEFutureFlight
}
