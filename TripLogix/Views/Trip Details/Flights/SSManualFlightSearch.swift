
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
//                                                    .padding(.top, 5)
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
                    
                    Group {
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
                                                    SSFlightCard(flight: flight)
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
    }
}

//struct FlightBookingView: View {
//    @State private var departureAirport = "CGK"
//    @State private var arrivalAirport = "LGA"
//
//    var body: some View {
//        //NavigationView {
//            VStack {
//                VStack {
//                    HStack {
//                        Image(systemName: "airplane.departure")
//                            .foregroundColor(.gray)
//                        TextField("Airport Code", text: $departureAirport)
//                    }
//                    Text("Soekarno Hatta International Airport")
//                }
//                .padding()
//                .cardStyleBordered()
//                
//                VStack {
//                    HStack {
//                        Image(systemName: "airplane.arrival")
//                            .foregroundColor(.gray)
//                        TextField("Airport Code", text: $arrivalAirport)
//                    }
//                    Text("New York La Guardia International Airport")
//                }
//                .padding()
//                .cardStyleBordered()
//            }
//            .padding()
//        //}
//    }
//}

struct SSFlightCard: View {
    
    var flight: SSItinerary
    
    var body: some View {
        
        Section() {
            VStack {
                ForEach(flight.legs, id: \.self) { leg in

                    HStack {
                        Spacer()
                        
                        Text("Stops: \(leg.stopCount)".uppercased())
                            .foregroundColor(.accentColor).bold()
                            .font(.system(size: 15))
                            .isHidden(leg.stopCount == 0)
                        
                        Text("\(flight.price.formatted)")
                            .padding(8)
                            .padding(.horizontal, 8)
                            .buttonStylePrimary(.secondary)
                    }
                        
                    ForEach(leg.segments, id: \.self) { segment in
                        
                        Group {
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(segment.origin.parent.name)")
                                    Text("\(segment.origin.flightPlaceId)")
                                        .font(.system(size: 22))
                                        .fontWeight(.bold)
                                    Text("\(extractTime(from: leg.departure))")
                                }
                                
                                Spacer()
                                VStack {
                                    Text("\(formatDateFlightCard(from: segment.departure))")
                                        .font(.system(size: 15)).bold()
                                    Image(systemName: "airplane")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                    Text("\(segment.marketingCarrier.alternateId) \(segment.flightNumber) (\(formatMinutes(segment.durationInMinutes)))")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray4)
                                        .padding(.horizontal)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(segment.destination.parent.name)")
                                    Text("\(segment.destination.flightPlaceId)")
                                        .font(.system(size: 22))
                                        .fontWeight(.bold)
                                    Text("\(extractTime(from: segment.arrival))")
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

struct SearchAirportsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: SSFlightsViewModel = SSFlightsViewModel()
    @State private var searchText: String = ""
    @State private var globalSearchText: String = ""
    var passCachedAirport: (SSAirport.SSAirportPresentation) -> Void
    @State private var selectedSegment = 0

    func loadCachedAirports() {
        viewModel.getCachedSSAirports()
    }
    
    var filteredAirports: [SSAirport.SSAirportPresentation] {
        if searchText.isEmpty {
            return viewModel.cachedSSAirports
        } else {
            return viewModel.cachedSSAirports.filter { $0.suggestionTitle.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "x.circle")
                    .font(.largeTitle)
                    .foregroundColor(.wbPinkMedium)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .padding()

            VStack {
                Picker("Options", selection: $selectedSegment) {
                    Text("Recent Searches").tag(0)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text("Search Airports").tag(1)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if selectedSegment == 0 {
                Form {
                    TextField("Filter Search History", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    
                    ForEach(Array(filteredAirports.reversed().enumerated()), id: \.element) { index, item in
                        HStack {
                            Image(item.subtitle.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "").flagIconSanitized() ?? "")
                                .resizable()
                                .frame(width: 24, height: 17)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text("\(item.suggestionTitle)")
                                .font(.custom("Gilroy-Medium", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 4)
                        }
                        .padding(8)
                        .onTapGesture {
                            passCachedAirport(item)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
            } else {
                
                Form {
                    TextField("Airport or City Name", text: $viewModel.query)
                        .textFieldStyle(.roundedBorder)
                    
                    ForEach(viewModel.globalSSAirports, id: \.self) { item in
                        HStack {
                            Image(item.presentation.subtitle.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "").flagIconSanitized() ?? "")
                                .resizable()
                                .frame(width: 24, height: 17)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text("\(item.presentation.suggestionTitle)")
                                .font(.custom("Gilroy-Medium", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 4)
                        }
                        .padding(8)
                        .onTapGesture {
                            viewModel.manageSSAirporteCache(item.presentation)
                            passCachedAirport(item.presentation)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            
        }
        .background(Color(UIColor.systemGroupedBackground))
        .presentationDetents([.fraction(0.6)])
        .onAppear {
            self.loadCachedAirports()
        }
    }
}
