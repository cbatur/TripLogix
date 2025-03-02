
import SwiftUI

struct ImageToFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = ImageToFlightViewModel()
    @State private var addVerificationActionSheet = false
    var actionPassFlights: ([SelectedFlight]) -> Void
    
    private var flightGroupsView: some View {
        ForEach(Array(viewModel.futureFlights.enumerated()), id: \.element.id) { index, group in
            Section {
                flightGroupHeaderView(for: group)
                flightsView(for: group, atIndex: index)
            }
        }
    }

    private func flightGroupHeaderView(for group: SelectedFlightGroup) -> some View {
        HStack {
            Text(formatDateDisplay(group.date).uppercased())
                .font(.custom("Gilroy-Bold", size: 17))
                .foregroundColor(Color.gray)
            Spacer()
        }
    }

    private func flightsView(for group: SelectedFlightGroup, atIndex index: Int) -> some View {
        VStack {
            ForEach(group.flights, id: \.self) { flight in
                flightView(for: flight, inGroupAtIndex: index)
            }
        }
        .padding(.bottom, 30)
    }

    private func flightView(for flight: AEFutureFlight, inGroupAtIndex index: Int) -> some View {
        VStack {
            Text("FlightREsultCard")
            //FlightResultCard(flight)
        }
        .padding()
        .cardStyle(isFlightSelected(flight, inGroupAtIndex: index) ? .tlAccentYellow : Color.white)
        .onTapGesture {
            viewModel.selectFlight(flightToSelect: flight, inGroupAtIndex: index)
        }
    }

    private func isFlightSelected(_ flight: AEFutureFlight, inGroupAtIndex index: Int) -> Bool {
        viewModel.selectedFlights[index]?.flight.id == flight.id && viewModel.selectedFlights[index]?.selected == true
    }
    
    private func addSelectedFlights() {
        actionPassFlights(Array(viewModel.selectedFlights.values))
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BannerWithDismiss(
                    dismiss: { presentationMode.wrappedValue.dismiss() },
                    headline: "Add Flights to Trip".uppercased(),
                    subHeadline: "Add your flight reservation screenshot"
                )
                .opacity(viewModel.activity() ? 0.4 : 1.0)

                VStack {
                    VStack { // CTA Buttons
                        if viewModel.selectedImage == nil {
                            HStack {
                                TLButton(.secondary, title: "Select image")
                                    .onTapGesture {
                                        viewModel.resetSearch()
                                        viewModel.showImagePicker = true
                                    }
                                    .isHidden(viewModel.activity())
                                
                                if viewModel.hasFlights() {
                                    TLButton(.green, title: "Add Flight(s)")
                                        .onTapGesture {
                                            addVerificationActionSheet = true
                                        }
                                }
                            }
                            
                        } else {
                            TLButton(.primary, title: "Scan This Flight Photo?")
                                .onTapGesture {
                                    viewModel.uploadSelectedImage()
                                }
                        }
                    }
                    .isHidden(viewModel.activity())
      
                    if let alert = viewModel.activeAlertBox {
                        AlertWithIconView(alertBox: alert)
                    }

                    viewModel.selectedImage?
                        .resizable()
                        .scaledToFit()

                    VStack {
                        HStack {
                            Text("SELECT YOUR FLIGHT(S)")
                                .font(.custom("Gilroy-Bold", size: 23))
                                .foregroundColor(Color.tlOrange)
                            Spacer()
                        }
                        Divider()
                            .padding(.bottom, 30)
                         
                        flightGroupsView
                    }
                    .isHidden(viewModel.futureFlights.isEmpty)
                    .padding(.top, 40)
                }
                .padding()
            }
            .disabled(viewModel.activity())
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .onChange(of: viewModel.flightsFromImage) { _, _ in
                viewModel.checkIfPastDate(from: viewModel.flightsFromImage)
            }
            .onChange(of: viewModel.flightImageUrl) { _, url in
                guard let imageUrl = url else { return }
                viewModel.getFlightParametersFromImage(imageUrl)
            }
            .actionSheet(isPresented: $addVerificationActionSheet) {
                ActionSheet(
                    title: Text("Add flights to itinerary"),
                    message: Text(viewModel.hasFlights() ? viewModel.getVerificationString() : "You did not select any flights."),
                    buttons: [
                        .default(Text(viewModel.hasFlights() ? "YES" : "OK")) {
                            if viewModel.hasFlights() {
                                addSelectedFlights()
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .analyticsScreen(name: "ImageToFlightView")
        }
    }
}
