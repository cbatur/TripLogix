
import SwiftUI

struct VerifyLegAlertView: View {
    @Binding var showAlert: Bool
    var segment: SSLeg.SSSegment?
    var actionSelectedFlight: (SSLeg.SSSegment) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text("Confirm Flight Addition")
                .font(.title)
                .fontWeight(.bold)
                .padding([.top, .bottom])

            if let segment = segment {
                SSSegmentCard(segment: segment)
                
                HStack {
                    Spacer()
                    Label("Add to My Trip", systemImage: "plus")
                        .padding(.horizontal, 15)
                        .padding(9)
                        .buttonStylePrimary(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            actionSelectedFlight(segment)
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
    var actionPassFlight: (SSLeg.SSSegment) -> Void
    
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
                        
                        SSSegmentCard(segment: segment)
                        .onTapGesture {
                            actionPassFlight(segment)
                        }
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
