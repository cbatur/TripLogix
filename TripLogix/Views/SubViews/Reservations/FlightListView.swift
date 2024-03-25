
import SwiftUI

struct FlightListView: View {
    var futureFlights: [AEFutureFlight]
    @State private var showingCustomActionSheet = false
    @State private var selectedFlight: AEFutureFlight?
    var actionPassFlight: (SelectedFlight) -> Void
    var flightDate: Date = Date()
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("\(futureFlights.count)")) {
                    ForEach(futureFlights, id: \.self) { item in
                        FlightResultCard(item)
                        .onTapGesture {
                            self.selectedFlight = item
                        }
                    }
                }
            }
        }
        .onChange(of: self.selectedFlight) { _, flight in
            guard let _ = flight else { return }
            self.showingCustomActionSheet = true
        }
        .customActionSheet(isPresented: $showingCustomActionSheet) {
            VStack {
                if let selectedFlight = selectedFlight {
                    FlightResultCardVerification(flight: selectedFlight)
                    Divider()
                    HStack {
                        Button("Add this flight".uppercased()) {
                            showingCustomActionSheet = false
                            actionPassFlight(SelectedFlight(date: self.flightDate, flight: selectedFlight))
                        }
                        .padding(6)
                        .padding(.leading, 6)
                        .padding(.trailing, 6)
                        .cardStyle(.green)
                        
                        Button {
                            showingCustomActionSheet = false
                        } label: {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Text("Something Went Wrong!".uppercased())
                    Divider()
                    Button("OK") {
                        showingCustomActionSheet = false
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
    
    func selectFlight(_ flight: AEFutureFlight) {
        self.selectedFlight = flight
        self.showingCustomActionSheet = true
    }
}

struct FlightResultCardVerification: View {
    var flight: AEFutureFlight
    
    var body: some View {
        VStack {
            Text(flight.departure.scheduledTime)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 2)
            Divider()
            Text("\(flight.departure.iataCode.uppercased()) ➔ \(flight.arrival.iataCode.uppercased())")
                .fontWeight(.semibold)
            Divider()
            Text(getSubTitle())
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    func getSubTitle() -> String {
        let f = flight
        let formattedAirlineName = f.airline.name.capitalizedFirstLetter()
        let subtitle = "\(f.airline.iataCode.uppercased()) \(f.flight.number) (\(f.airline.icaoCode.uppercased()) ➔ \(formattedAirlineName))"
        return subtitle
    }
}

struct FlightResultCard: View {
    var flight: AEFutureFlight
    
    init(_ flight: AEFutureFlight) {
        self.flight = flight
    }
    
    func getSubTitle() -> String {
        let f = flight
        let formattedAirlineName = f.airline.name.capitalizedFirstLetter()
        let subtitle = "\(f.airline.iataCode.uppercased()) \(f.flight.number) (\(f.airline.icaoCode.uppercased()) ➔ \(formattedAirlineName))"
        return subtitle
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(flight.departure.scheduledTime)
                    .fontWeight(.semibold)
            }
            Image(systemName: "airplane.circle")
            VStack(alignment: .leading) {
                Text("\(flight.departure.iataCode.uppercased()) ➔ \(flight.arrival.iataCode.uppercased())")
                    .fontWeight(.semibold)
                Text(getSubTitle())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct D_FlightResultCard: View {
    var flight: DFutureFlight
    
    init(_ flight: DSelectedFlight) {
        self.flight = flight.flight
    }
    
    func getSubTitle() -> String {
        let f = flight
        let formattedAirlineName = f.airline.name.capitalizedFirstLetter()
        let subtitle = "\(f.airline.iataCode.uppercased()) \(f.flight.number) (\(f.airline.icaoCode.uppercased()) ➔ \(formattedAirlineName))"
        return subtitle
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(flight.departure.scheduledTime)
                    .fontWeight(.semibold)
            }
            Image(systemName: "airplane.circle")
            VStack(alignment: .leading) {
                Text("\(flight.departure.iataCode.uppercased()) ➔ \(flight.arrival.iataCode.uppercased())")
                    .fontWeight(.semibold)
                Text(getSubTitle())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
