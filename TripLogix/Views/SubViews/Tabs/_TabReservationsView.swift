
import SwiftUI

struct _TabReservationsView: View {
    @Bindable var destination: Destination
    @State private var displayBottomToolbar = true
    @State private var flightManageViewDisplay = false
    @State private var deleteFlight = false
    @State private var flightToDelete: DSelectedFlight?

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func deleteFlight(_ flight: DSelectedFlight) {
        destination.flights.removeAll { $0.id == flight.id }
        deleteFlight = false
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
                                Button {
                                    flightManageViewDisplay = true
                                } label: {
                                    Text("FLIGHTS")
                                        .font(.custom("Satoshi-Bold", size: 15))
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                        .cardStyle(.black.opacity(0.5))
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

