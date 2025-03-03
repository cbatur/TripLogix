import SwiftUI

struct FlightResultsView: View {
    @StateObject var viewModel = FlightsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    let departureAirport: Airport
    let arrivalAirport: Airport
    let date: Date
    
    @State private var selectedFlightID: String?
    @Binding var selectedFlight: Leg?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        routeSummary

                        if viewModel.isFlightSearchLoading {
                            ForEach(PlaceholderItem.placeholders) { _ in
                                FlightSkeletonView()
                            }
                        } else if viewModel.flightResults.isEmpty {
                            NoFlightsFoundView()
                        } else {
                            VStack {
                                ForEach(viewModel.flightResults, id: \.self) { flight in
                                    FlightResultsCardView(
                                        id: flight.legs[0].id,
                                        airlineName: flight.legs[0].carriers.marketing[0].name,
                                        flightNumber: "\(flight.legs[0].carriers.marketing[0].name) \(flight.legs[0].segments[0].flightNumber)",
                                        airlineImageName: flight.legs[0].carriers.marketing[0].logoUrl,
                                        departureTime: extractTime(from: flight.legs[0].departure),
                                        departureAirport: flight.legs[0].origin.displayCode,
                                        duration: formatMinutes(flight.legs[0].durationInMinutes),
                                        arrivalTime: extractTime(from: flight.legs[0].arrival),
                                        arrivalAirport: flight.legs[0].destination.displayCode,
                                        isSelected: flight.legs[0].id == selectedFlightID,
                                        onSelect: {
                                            selectedFlightID = flight.legs[0].id
                                        }
                                    )
                                }
                            }
                            .padding(.bottom, 80)
                        }
                    }
                    .animation(.easeInOut, value: viewModel.flightResults)
                    .padding(.top, 84)
                    .padding(.horizontal, 16)
                }
                
                topNav
                    .padding(.top, 15)

                bottomBar
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await viewModel.searchFlights(date: formatDateParameter(date), origin: departureAirport.presentation.skyId, destination: arrivalAirport.presentation.skyId)
            }
        }
    }
        
    private func receiveSelectedFlight() {
        guard let selectedFlightID = selectedFlightID else {
            print("No selectedFlightID found")
            return
        }
        
        if let itinerary = viewModel.flightResults.first(where: { $0.legs[0].id == selectedFlightID }) {
            selectedFlight = itinerary.legs[0]
            self.presentationMode.wrappedValue.dismiss()
        } else {
            print("No itinerary matches the selectedFlightID: \(selectedFlightID)")
        }
    }
}

// MARK: - Subviews
extension FlightResultsView {
    private var topNav: some View {
        VStack {
            HStack(spacing: 12) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Select Flight")
                        .foregroundStyle(Color.slSofiColor)
                        .font(.headline)
                    Text("Choose one flight to add to your trip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .position(x: UIScreen.main.bounds.midX, y: 28) // to keep it "fixed" at top
        .zIndex(1)
    }

    /// Route Summary (SFO → JFK, date)
    private var routeSummary: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 4) {
                    Text("\(departureAirport.presentation.skyId)").font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.subheadline)
                    Text("\(arrivalAirport.presentation.skyId)").font(.headline)
                }
                Spacer()
                Text("\(formatDateParameter(date))")
                    .font(.subheadline)
            }
            Text("\(departureAirport.presentation.title) to \(arrivalAirport.presentation.title)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(Color.blue)
        .cornerRadius(12)
        .foregroundColor(.white)
    }

    /// Bottom bar with "Add Selected Flight to Trip"
    private var bottomBar: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    receiveSelectedFlight()
                } label: {
                    Text("Add Selected Flight to Trip")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue).opacity(selectedFlightID == nil ? 0.4 : 1.0)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .isHidden(selectedFlightID == nil)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct RoundedCornerD: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
