import SwiftUI

struct FlightSearchView: View {
    @StateObject var departureViewModel = AirportsViewModel(mode: .departure)
    @StateObject var arrivalViewModel = AirportsViewModel(mode: .arrival)
    @Binding var selectedDate: Date
    @State private var showingFlightResults = false
    @FocusState private var isInputActive: Bool
    @State private var selectedFlight: Leg?
    var passSelectedFlight: (Leg) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Add a flight")
                .font(.title2)
                .foregroundStyle(.black)
                .bold()
                .padding(.bottom, 15)

            AirportSearchField(viewModel: departureViewModel, placeholder: "Departure airport", icon: "airplane.departure")
            
            HStack {
                Spacer()
                Button(action: swapAirports) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .bold))
                        .padding(10)
                        .background(Color.blue.opacity(departureViewModel.selectedAirport == nil || arrivalViewModel.selectedAirport == nil ? 0.1 : 0.8))
                        .clipShape(Circle())
                }
                .disabled(departureViewModel.selectedAirport == nil || arrivalViewModel.selectedAirport == nil)
                Spacer()
            }

            AirportSearchField(viewModel: arrivalViewModel, placeholder: "Arrival airport", icon: "airplane.arrival")

            DateInputField(selectedDate: $selectedDate)

            Button(action: {
                showingFlightResults = true
            }) {
                Text("Search Flights")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color.blue.opacity(
                            departureViewModel.selectedAirport == nil || arrivalViewModel.selectedAirport == nil ? 0.1 : 0.8
                        )
                    )
                    .foregroundColor(.white)
                    .font(.headline)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .onChange(of: selectedFlight) { _, newFlight in
                if let flight = newFlight {
                    self.passSelectedFlight(flight)
                }
            }
            .disabled(departureViewModel.selectedAirport == nil || arrivalViewModel.selectedAirport == nil)
            .sheet(isPresented: $showingFlightResults) {
                if let departureAirport = departureViewModel.selectedAirport,
                   let arrivalAirport = arrivalViewModel.selectedAirport {
                    FlightResultsView(
                        departureAirport: departureAirport,
                        arrivalAirport: arrivalAirport,
                        date: selectedDate,
                        selectedFlight: $selectedFlight
                    )
                } else {
                    Text("No flight selected.")
                        .font(.title)
                }
            }
        }
    }

    func swapAirports() {
        guard let departure = departureViewModel.selectedAirport,
              let arrival = arrivalViewModel.selectedAirport else {
            return
        }

        let tempQuery = departureViewModel.searchQuery
        departureViewModel.searchQuery = arrivalViewModel.searchQuery
        arrivalViewModel.searchQuery = tempQuery

        departureViewModel.selectedAirport = arrival
        arrivalViewModel.selectedAirport = departure
    }
}
