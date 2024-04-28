
import SwiftUI

struct LocationDateHeader: View {
    @Bindable var destination: Destination
    let tripLinks: [String] = ["Events", "Hotels", "Flights", "Documents"]
    @State private var selectedLink: String = "Events"
    let columns: [GridItem] = [GridItem(.flexible())]
    var linksHidden: Bool = false
    
    init(destination: Destination, linksHidden: Bool = false) {
        _destination = Bindable(wrappedValue: destination)
        self.linksHidden = linksHidden
    }
    
    func dayDiff() -> Int {
        return daysBetween(start: destination.startDate, end: destination.endDate)
    }
    
    func dayDiffLabel() -> String {
        let ext = dayDiff() == 0 ? "day" : "days"
        return " (\(dayDiff()) \(ext))"
    }
    
    var body: some View {
        HStack {
            DestinationIconDataView(iconData: destination.icon, size: 70)
            
            VStack {
                CityTitleHeader(cityName: destination.name)
                    .frame(alignment: .leading)
                
                HStack {
                    Text("\(destination.startDate.formatted(date: .abbreviated, time: .omitted)) - \(destination.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14))
                        .foregroundColor(.gray3) +
                    Text(dayDiffLabel())
                        .foregroundColor(.gray)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

struct TripLinks: View {
    
    let tripLinks: [String] = ["Events", "Flights", "Hotels", "Rentals", "Docs"]
    let tripIcons: [String] = ["map", "airplane", "house", "car", "doc"]
    @State private var selectedLink: String = "Events"
    let columns: [GridItem] = [GridItem(.flexible())]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(tripLinks.indices, id: \.self) { index in
                    VStack {
                        Image(systemName: tripIcons[index])
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 3)
                        
                        Text(tripLinks[index].uppercased())
                            .font(.custom("Satoshi-Bold", size: 13))
                            .foregroundColor(
                                self.selectedLink == tripLinks[index] ? Color.wbPinkMedium : Color.gray
                            )
                    }
                    .padding(6)
                    .onTapGesture {
                        self.selectedLink = tripLinks[index]
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

