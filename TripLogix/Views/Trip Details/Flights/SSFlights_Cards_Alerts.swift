
import SwiftUI

struct DeleteFlightAlert: View {
    @Binding var showAlert: Bool
    var leg: DSSLeg?
    var actionSelectedLeg: (DSSLeg) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text("Confirm Flight Deletion")
                .font(.title)
                .fontWeight(.bold)
                .padding([.top, .bottom])

            if let leg = leg {
                ForEach(leg.segments, id: \.self) { segment in
                    DSSSegmentCard(segment: segment)
                }
                
                HStack {
                    Spacer()
                    Label("Delete from My Trip", systemImage: "trash")
                        .padding(.horizontal, 15)
                        .padding(9)
                        .buttonStylePrimary(.pink)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            actionSelectedLeg(leg)
                            showAlert = false
                        }
                    
                    Button("Cancel") {
                        showAlert = false
                    }
                    .padding()
                    .foregroundColor(.accentColor)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.tlAccentYellow)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct VerifyLegAlertView: View {
    @Binding var showAlert: Bool
    var leg: SSLeg?
    var actionSelectedLeg: (SSLeg) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text("Confirm Flight Addition")
                .font(.title)
                .fontWeight(.bold)
                .padding([.top, .bottom])

            if let leg = leg {
                ForEach(leg.segments, id: \.self) { segment in
                    SSSegmentCard(segment: segment)
                }
                
                HStack {
                    Spacer()
                    Label("Add to My Trip", systemImage: "plus")
                        .padding(.horizontal, 15)
                        .padding(9)
                        .buttonStylePrimary(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            actionSelectedLeg(leg)
                            showAlert = false
                        }
                    
                    Button("Cancel") {
                        showAlert = false
                    }
                    .padding()
                    .foregroundColor(.accentColor)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.tlAccentYellow)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SSFlightCard: View {
    var flight: SSItinerary
    var actionPassFlight: (SSLeg) -> Void
    
    var body: some View {
        Section() {
            VStack {
                ForEach(flight.legs, id: \.self) { leg in
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.tlGreen)
                            .font(.title)
                            .onTapGesture {
                                actionPassFlight(leg)
                            }
                        
                        Spacer()
                        
                        Text("Stops: \(leg.stopCount)".uppercased())
                            .foregroundColor(.tlOrange).bold()
                            .font(.system(size: 15))
                            .isHidden(leg.stopCount == 0)
                        
                        Text("\(flight.price.formatted)")
                            .padding(8)
                            .padding(.horizontal, 8)
                            .buttonStylePrimary(.secondary)
                    }
                        
                    ForEach(leg.segments, id: \.self) { segment in
                        SSSegmentCard(segment: segment)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

struct SSSegmentCard: View {
    var segment: SSLeg.SSSegment
    
    var body: some View {
        Group {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("\(segment.origin.parent.name)")
                    Text("\(segment.origin.flightPlaceId)")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                    Text("\(extractTime(from: segment.departure))")
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
    }
}

struct DSSSegmentCard: View {
    var segment: DSSSegment
    
    var body: some View {
        Group {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(segment.origin.parent.name)")
                    Text("\(segment.origin.flightPlaceId)")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                    Text("\(extractTime(from: segment.departure))")
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
                .padding(.vertical)
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
    }
}
