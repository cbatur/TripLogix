
import SwiftUI

struct SS_ManualFlightSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Bindable var destination: Destination
    @StateObject var viewModel: SSFlightsViewModel = SSFlightsViewModel()

    @State private var textFrom = ""
    @State private var textTo = ""
    @State private var launchCachedAirports = false
    @State private var flightDate = Date()
    @State private var isRotating = false
    
    @State private var fromAirport: SSAirport.SSAirportPresentation?
    @State private var toAirport: SSAirport.SSAirportPresentation?
    
    @FocusState private var fromInputActive: Bool
    @FocusState private var toInputActive: Bool
    @State private var isFromListActive: Bool = true
    
    @State private var selectedSegment = 0
    @State private var showVerificationFlightAlert = false
    @State private var selectedLeg: SSLeg?
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
        _flightDate = State(initialValue: destination.startDate)
    }
    
    func setAirports(_ airport: SSAirport.SSAirportPresentation) {
        if isFromListActive {
            self.fromAirport = airport
            textFrom = airport.suggestionTitle
        } else {
            self.toAirport = airport
            textTo = airport.suggestionTitle
        }
    }
    
    func swapAirports() {
        let newTo = fromAirport
        let newFrom = toAirport
        
        fromAirport = newFrom
        toAirport = newTo
        
        textTo = toAirport?.suggestionTitle ?? ""
        textFrom = fromAirport?.suggestionTitle ?? ""
    }
    
    func searchEnabled() -> Bool {
        return fromAirport != nil && toAirport != nil
    }
    
    func receiveSelectedFlight(_ leg: SSLeg) {
        self.selectedLeg = leg
        
        for segment in leg.segments {
            print("[Debug] \(segment.departure)")
        }
        
        showVerificationFlightAlert = true
    }
    
    func addFlightToTrip(_ s: SSLeg) {
        print("pass to Viewmodel and add flight")
        
        if !destination.flightLegs.contains(where: { $0.id == s.id }) {
        
            destination.flightLegs.append(convertFlight(s))
            
//            AnalyticsManager.shared.logEvent(
//                name: "_TabReservationsView_AddFlight",
//                params: ["added_flight": simplfyFlightInfo(s)]
//            )
        }
        
        // Display a toaster here that the flight has been added.
        presentationMode.wrappedValue.dismiss()
    }
    
    // Move Public FlightMethods to here
    func convertFlight(_ s: SSLeg) -> DSSLeg {

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
    
    var body: some View {

        VStack {
            HStack {
                Image(systemName: "x.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray4)
                    .padding()
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                Spacer()
                Text("Let's get you to ")
                    .font(.custom("Gilroy-Regular", size: 21))
                    .foregroundColor(.wbPinkMedium) +
                Text("places...")
                    .font(.custom("Gilroy-Bold", size: 21))
                    .foregroundColor(.wbPinkMedium)
            }
            .padding(.trailing, 20)
            .background(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                Picker("Options", selection: $selectedSegment) {
                    Text("Search").tag(0)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    if searchEnabled() && viewModel.searchModeOn {
                        Text("Results").tag(1)
                            .background(Color.green)
                            .foregroundColor(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            }
            
                if selectedSegment == 0 {
                    Group { // Search View
                        VStack (alignment: .leading) {
                            HStack {
                                VStack {
                                    HStack {
                                        VStack {
                                            Image(systemName: "airplane.departure")
                                                .foregroundColor(.gray)
                                            Text("From")
                                                .foregroundColor(.gray5)
                                                .font(.caption)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            if let airport = self.fromAirport {
                                                Text("\(airport.suggestionTitle)")
                                                    .font(.system(size: 18))
                                                    .fontWeight(.medium)
                                                Text("\(airport.subtitle)")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.gray3)
                                            } else {
                                                Text("Select Departure Airport")
                                                    .font(.system(size: 17))
                                                    .foregroundColor(.gray3)
                                                    .fontWeight(.medium)
                                            }
                                        }
                                        .padding(.leading, 5)
                                        
                                        Spacer()
                                        
                                        if let airport = self.fromAirport {
                                            Image(airport.subtitle.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "").flagIconSanitized() ?? "")
                                                .resizable()
                                                .frame(width: 24, height: 17)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                            
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundColor(.gray)
                                        }
                                        
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(30)
                                    .onTapGesture {
                                        launchCachedAirports = true
                                        isFromListActive = true
                                    }
                                    
                                    HStack {
                                        VStack {
                                            Image(systemName: "airplane.arrival")
                                                .foregroundColor(.gray)
                                            Text("To")
                                                .foregroundColor(.gray5)
                                                .font(.caption)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            if let airport = self.toAirport {
                                                Text("\(airport.suggestionTitle)")
                                                    .font(.system(size: 18))
                                                    .fontWeight(.medium)
                                                Text("\(airport.subtitle)")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.gray3)
                                            } else {
                                                Text("Select Arrival Airport")
                                                    .font(.system(size: 17))
                                                    .foregroundColor(.gray3)
                                                    .fontWeight(.medium)
                                            }
                                        }
                                        .padding(.leading, 5)
                                        
                                        Spacer()
                                        
                                        if let airport = self.toAirport {
                                            Image(airport.subtitle.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "").flagIconSanitized() ?? "")
                                                .resizable()
                                                .frame(width: 24, height: 17)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                            
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundColor(.gray)
                                        }
                                        
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(30)
                                    .onTapGesture {
                                        launchCachedAirports = true
                                        isFromListActive = false
                                    }
                                    
                                }
                                VStack(alignment: .center) {
                                    Image(systemName: "arrow.triangle.swap")
                                        .foregroundColor(.tlOrange)
                                        .font(.headline)
                                        .onTapGesture {
                                            swapAirports()
                                        }
                                }
                            }
                            
                            DatePicker(
                                "Select Flight Date",
                                selection: $flightDate,
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                            .padding(.top, 15)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            
                            Spacer()
                            
                            Label("Search Flights", systemImage: "magnifyingglass")
                                .padding(.horizontal, 15)
                                .padding(9)
                                .buttonStylePrimary(.green)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(!self.searchEnabled())
                                .opacity(searchEnabled() ? 1.0 : 0.3)
                                .onTapGesture {
                                    self.isRotating = false
                                    selectedSegment = 1
                                    
                                    viewModel.searchFlights(formatDateParameter(flightDate), d: fromAirport?.id ?? "", a: toAirport?.id ?? "")
                                }
                        }
                        .padding(.horizontal, 13)
                    }
                    
                } else {
                    
                    Group { // Search Rrsults Flights List View
                        VStack {
                            Form {
                                
                                if let from = fromAirport, let to = toAirport {
                                    VStack (alignment: .leading) {
                                        HStack {
                                            Text("\(from.suggestionTitle)")
                                                .font(.system(size: 17)).bold()
                                            Text(" ➔ ")
                                            Text("\(to.suggestionTitle)")
                                                .font(.system(size: 17)).bold()
                                        }
                                        .padding(.bottom, 5)
                                        
                                        Text("\(formatDateDisplay(flightDate))")
                                            .font(.subheadline)
                                    }
                                    .padding([.leading])
                                    
                                    if viewModel.searchModeOn {
                                        if viewModel.searchLoading {
                                            HStack {
                                                Spacer()
                                                VStack {
                                                    Text("Fetching Flights...")
                                                        .foregroundColor(.wbPinkMedium)
                                                        .font(.system(size: 25)).bold()
                                                        .padding([.top])
                                                    Image("spinning_logo_trans")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .opacity(0.7)
                                                        .frame(width: 200, height: 200)
                                                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                                                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isRotating)
                                                        .onAppear() {
                                                            self.isRotating = true
                                                        }
                                                }
                                                Spacer()
                                            }
                                            
                                        } else {
                                            
                                            if viewModel.itineraries.count > 0 {
                                                ForEach(viewModel.itineraries, id: \.self) { flight in
                                                    SSFlightCard(flight: flight, actionPassFlight: receiveSelectedFlight)
                                                }
                                            } else {
                                                VStack {
                                                    Image("empty_screen_airport")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .background(Color.clear)
                                                    Text("No flights found")
                                                        .font(.custom("Gilroy-Medium", size: 22))
                                                        .foregroundColor(.gray)
                                                    
                                                    Label("Search Again", systemImage: "magnifyingglass")
                                                        .padding(.horizontal, 15)
                                                        .padding(9)
                                                        .buttonStylePrimary(.green)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .disabled(!self.searchEnabled())
                                                        .opacity(searchEnabled() ? 1.0 : 0.3)
                                                        .onTapGesture {
                                                            self.isRotating = false
                                                            selectedSegment = 1
                                                            
                                                            viewModel.searchFlights(formatDateParameter(flightDate), d: fromAirport?.id ?? "", a: toAirport?.id ?? "")
                                                        }
                                                        .padding(.top, 20)
                                                }
                                                .padding(.leading, 45)
                                                .padding(.trailing, 45)
                                                .frame(alignment: .center)
                                            }
                                        }
                                    } else {
                                        Text("Search For flights here -> Button etc.")
                                    }
                                    
                                } else {
                                    HStack {
                                        Text("Select Dates")
                                        Spacer()
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                viewModel.pullAirportFromCache(destination)
            }
            .sheet(isPresented: $launchCachedAirports) {
                SearchAirportsView(passCachedAirport: setAirports)
            }
            .onChange(of: viewModel.toAirport) { _, airport in
                self.toAirport = airport
            }
            .onChange(of: viewModel.fromAirport) { _, airport in
                self.fromAirport = airport
            }
            .customAlert(isVisible: $showVerificationFlightAlert,
                         content: {
                VerifyLegAlertView(
                    showAlert: $showVerificationFlightAlert,
                    leg: selectedLeg,
                    actionSelectedLeg: addFlightToTrip
                )
                .padding()
            })
    }
}
