import SwiftUI

//struct FlightsHomeView2: View {
//    @Bindable var destination: Destination
//    @StateObject var viewModel: FlightsViewModel = FlightsViewModel()
//
////    @State private var displayBottomToolbar = true
////    @State private var flightManageViewDisplay = false
////    @State private var deleteFlight = false
////    @State private var flightToDelete: DSSLeg?
////    @State var launchImageToFlightView = false
////
////    // New State variables
////    @State private var flightDate: Date = Date()
////    @State private var flightNumber: String = ""
////    @State private var isExpanded: Bool = false
////    @State private var verifyFlightView: Bool = false
//
//    init(destination: Destination) {
//        _destination = Bindable(wrappedValue: destination)
//    }
//
//    @State private var departureAirport: String = ""
//    @State private var arrivalAirport: String = ""
//    @State private var selectedDate: Date = Date()
//
//    var body: some View {
//        VStack {
//            FlightSearchFormView(departureAirport: $departureAirport, arrivalAirport: $arrivalAirport, selectedDate: $selectedDate)
//                    .padding()
//                    .cardStyle(.white)
//                    .padding()
//        }
//    }
//
////    private var flightViewContent: some View {
////        VStack {
////            //if destination.flightLegs.count > 0 {
////                flightsListView
////
//////            } else {
//////                expandableFlightSearchView
//////                    .padding()
//////                    .cardStyle(.white)
//////                    .padding()
//////            }
////        }
////    }
//
////    private var expandableFlightSearchView: some View {
////        VStack(spacing: 5) {
////            Button(action: {
////                withAnimation {
////                    isExpanded.toggle()
////                }
////            }) {
////                HStack {
////                    Text("Find your flight".uppercased())
////                        .foregroundStyle(Color.slSofiColor)
////                        .font(.system(size: 16, weight: .medium))
////                    Spacer()
////                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
////                        .foregroundStyle(.gray)
////                        .font(.headline)
////                }
////            }
////
//////            if isExpanded {
//////                FlightSearchFormView(departureAirport: $departureAirport, arrivalAirport: $arrivalAirport, selectedDate: $selectedDate)
//////                    .transition(.slide)
//////            }
////        }
////    }
//
//
//
////
////
////    private var flightSearchView: some View {
////        VStack(spacing: 5) {
////            HStack {
////                Text("Enter your flight information")
////                    .font(.caption)
////                    .foregroundColor(.black)
////                Spacer()
////            }
////            Divider()
////            HStack {
////                Text("Flight Date")
////                    .foregroundStyle(.gray)
////                    .font(.subheadline)
////                    .bold()
////                Spacer()
////                DatePicker("", selection: $flightDate, displayedComponents: .date)
////                    .labelsHidden()
////                    .datePickerStyle(.automatic)
////                    .frame(maxWidth: .infinity, alignment: .leading)
////            }
////
////            HStack {
////                Text("Flight Number")
////                    .foregroundStyle(.gray)
////                    .font(.subheadline)
////                    .bold()
////                TextField("AC 1234", text: $flightNumber)
////                    .padding()
////                    .foregroundStyle(.black)
////                    .background(Color(UIColor.systemGray6))
////                    .cornerRadius(8)
////                    .keyboardType(.numbersAndPunctuation)
////            }
////
////            Spacer()
////
////            Button(action: {
////                Task {
////                    await viewModel.getFutureFlights()
////                }
////            }) {
////                Text("Search Flight".uppercased())
////                    .frame(maxWidth: .infinity)
////                    .padding()
////                    .background(Color.slSofiColor)
////                    .foregroundColor(.white)
////                    .cornerRadius(8)
////            }
////        }
////        .padding(.vertical, 5)
////        .padding(.top, 15)
////    }
//
////    private var noFlightView: some View {
////        GeometryReader { geometry in
////            VStack {
////                Image("hero_add_flight")
////                    .resizable()
////                    .scaledToFit()
////                    .background(Color.clear)
////                    .edgesIgnoringSafeArea(.all)
////                    .padding(.leading, geometry.size.width / 4)
////                    .padding(.trailing, geometry.size.width / 4)
////                Text("Add flights to trip")
////                    .font(.custom("Gilroy-Bold", size: 23))
////                    .foregroundColor(Color.black)
////                    .padding(.bottom, 10)
////                Text("A trip itinerary will be created for the dates you selected.")
////                    .font(.custom("Gilroy-Regular", size: 18))
////                    .foregroundColor(Color.gray3)
////                    .frame(alignment: .center)
////
////                buttonsToolBar
////            }
////            .padding(.leading, 15)
////            .padding(.trailing, 15)
////            .padding(.top, 15)
////        }
////    }
//
////    private var flightsListView: some View {
////        Form {
////            ForEach(sortFlightsByDate(destination.flightLegs), id: \.self) { leg in
////                Section(header:
////                    VStack {
////                        HStack {
////                            AsyncImage(url: URL(string: "\(leg.carriers.marketing.first?.logoUrl ?? "")")) { image in
////                                        image
////                                            .resizable()
////                                            .scaledToFit()
////                                    } placeholder: {
////                                        ProgressView()
////                                    }
////                                    .frame(width: 25, height: 25)
////
////                            Text("\(leg.carriers.marketing.first?.name ?? "")")
////                                .font(.subheadline)
////
////                            Text(leg.stopCount > 0 ? "Stops: \(leg.stopCount)" : "")
////                                .foregroundColor(.tlOrange).bold()
////
////                            Spacer()
////                            Image(systemName: "trash")
////                                .font(.headline )
////                                .onTapGesture {
////                                    flightToDelete = nil
////                                    flightToDelete = leg
////                                    deleteFlight = true
////                                }
////                        }
////                    }
////                ) {
////                    ForEach(sortSegmentsByDate(leg.segments), id: \.self) { segment in
////                        DSSSegmentCard(segment: segment)
////                    }
////                }
////            }
////        }
////        .opacity(0.8)
////        .clipShape(RoundedRectangle(cornerRadius: 13))
////        .frame(maxWidth: .infinity)
////    }
//
////    private var popUpMenu: some View {
////        VStack {
////            HStack {
////                HeaderView(title: destination.flightLegs.count == 0 ? "You do not have any flights" : "Flights in my trip")
////                Spacer()
////            }
////        }
////    }
//
////    private var buttonsToolBar: some View {
////        VStack {
////            buttonAddManually
////            buttonFromImage
////            buttonFromEmail
////        }
////        .padding(.leading, 35)
////        .padding(.trailing, 35)
////        .padding(.top, 20)
////    }
////
////    private var buttonAddManually: some View {
////        Button(action: { flightManageViewDisplay = true }) {
////            Label("Add Manually", systemImage: "airplane")
////            .padding(.horizontal, 15)
////            .padding(9)
////        }
////        .frame(maxWidth: .infinity)
////        .buttonStylePrimary(.pink)
////    }
////
////    private var buttonFromImage: some View {
////        Button(action: { launchImageToFlightView = true }) {
////            Label("Add From Image", systemImage: "photo")
////            .padding(.horizontal, 15)
////            .padding(9)
////        }
////        .frame(maxWidth: .infinity)
////        .buttonStylePrimary(.primary)
////    }
////
////    private var buttonFromEmail: some View {
////        Button(action: {
////            // Action For Email
////        }) {
////            Label("Add From Email", systemImage: "at.badge.plus")
////            .padding(.horizontal, 15)
////            .padding(9)
////        }
////        .frame(maxWidth: .infinity)
////        .buttonStylePrimary(.orange)
////    }
//}

//extension FlightsHomeView {
//
//    func deleteFlight(_ flight: DSSLeg) {
//        destination.flightLegs.removeAll { $0.id == flight.id }
//        deleteFlight = false
//    }
//
//    // Process response received from Image Scan
//    func passSelectedFlights(_ selectedFlights: [SelectedFlight]) {
//        for s in selectedFlights {
////            if !destination.flights.contains(convertFlight(s)) {
////                destination.flights.append(convertFlight(s))
////
////                AnalyticsManager.shared.logEvent(
////                    name: "_TabReservationsView_AddFlight",
////                    params: ["added_flight": simplfyFlightInfo(s)]
////                )
////            }
//        }
//    }
//
//    private func simplfyFlightInfo(_ f: SelectedFlight) -> String {
//        return "\(f.flight.departure.iataCode.uppercased()) ➔ \(f.flight.arrival.iataCode.uppercased()) - \(f.flight.airline.iataCode.uppercased()) \(f.flight.flight.number)\n"
//    }
//
//    func sortFlightsByDate(_ segments: [DSSLeg]) -> [DSSLeg] {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//        let sortedSegments = segments.sorted { (lhs, rhs) -> Bool in
//            if let lhsDate = formatter.date(from: lhs.departure), let rhsDate = formatter.date(from: rhs.departure) {
//                return lhsDate < rhsDate
//            }
//            return false
//        }
//        return sortedSegments
//    }
//
//    func sortSegmentsByDate(_ segments: [DSSSegment]) -> [DSSSegment] {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//        let sortedSegments = segments.sorted { (lhs, rhs) -> Bool in
//            if let lhsDate = formatter.date(from: lhs.departure), let rhsDate = formatter.date(from: rhs.departure) {
//                return lhsDate < rhsDate
//            }
//            return false
//        }
//        return sortedSegments
//    }
//}
