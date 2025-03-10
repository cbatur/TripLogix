
import SwiftUI

struct LocationDateHeader: View {
    @Bindable var destination: Destination
    @State private var selectedLink: String = "Events"

    let passDateClick: () -> Void
    let passIconClick: () -> Void
    
    init(
        destination: Destination,
        passDateClick: @escaping () -> Void,
        passIconClick: @escaping () -> Void
    ) {
        _destination = Bindable(wrappedValue: destination)
        self.passDateClick = passDateClick
        self.passIconClick = passIconClick
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
            DestinationIconDataView(iconData: destination.icon, size: 57)
                .onTapGesture { passIconClick() }
            
            VStack {
                CityTitleHeader(cityName: destination.name)
                    .frame(alignment: .leading)
                
                HStack {
                    Text("\(destination.startDate.formatted(date: .abbreviated, time: .omitted)) - \(destination.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14))
                        .foregroundColor(.white) +
                    Text(dayDiffLabel())
                        .foregroundColor(.yellow)
                    
                }
                .onTapGesture { passDateClick() }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

enum TripLink {
    case events
    case flights
    case hotels
    case rentals
    case docs
    
    var title: String {
        switch self {
        case .events:
            return "Events"
        case .flights:
            return "Flights"
        case .hotels:
            return "Hotels"
        case .rentals:
            return "Rentals"
        case .docs:
            return "Docs"
        }
    }
    
    var icon: String {
        switch self {
        case .events:
            return "map"
        case .flights:
            return "airplane"
        case .hotels:
            return "house"
        case .rentals:
            return "car"
        case .docs:
            return "doc"
        }
    }
    
}

struct TripLinks: View {
    
    let tripLinks: [TripLink] = [.events, .flights, .hotels, .rentals, .docs]
    @State private var selectedLink: TripLink = .events
    let passSelectedIndex: (Int) -> Void
    
    var body: some View {
        VStack {
            HStack {
                ForEach(tripLinks.indices, id: \.self) { index in
                    VStack(spacing: 5) {
                        Image(systemName: tripLinks[index].icon)
                            .font(.system(size: self.selectedLink == tripLinks[index] ? 22 : 20))
                            .foregroundColor(
                                self.selectedLink == tripLinks[index] ? Color.slSofiColor : Color.gray
                            )
                        //if self.selectedLink != tripLinks[index] {
                            Text(tripLinks[index].title.uppercased())
                                .font(.custom("Satoshi-Bold", size: 13))
                                .foregroundColor(
                                    self.selectedLink == tripLinks[index] ? Color.slSofiColor : Color.gray
                                )
                        //}
                    }
                    .frame(maxWidth: .infinity) // Ensures equal spacing for all items
                    .contentShape(Rectangle()) // Makes the whole area tappable
                    .onTapGesture {
                        self.selectedLink = tripLinks[index]
                        self.passSelectedIndex(index)
                    }
                }
            }
            .frame(height: 70)
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

