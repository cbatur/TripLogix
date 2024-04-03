
import SwiftUI

struct _TabItineraryView: View {
    @Bindable var destination: Destination
    @StateObject var viewModel: TabItineraryViewModel = TabItineraryViewModel()

    @State private var launchAllEvents = false
    @State private var isAnimating = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        VStack {
            if let alert = viewModel.activeAlertBox {
                AlertWithIconView(alertBox: alert)
                .cardStyle(.white)
            } else {
                VStack {
                    HStack {
                        TLButton(.transDark, title: destination.itinerary.isEmpty ? "Create a Plan" : "Manage Trip")
                            .onTapGesture {
                                self.updateTrip()
                            }
                    }
                }
                .isHidden(!viewModel.showUpdateButton())
                
                Form {
                    VStack {
                        Text("\(formatDateDisplay(destination.startDate))")
                            .font(.caption)
                            .foregroundStyle(Color.black)
                        Text("\(formatDateDisplay(destination.endDate))")
                            .font(.caption)
                            .foregroundStyle(Color.black)
                    }
                    
                    ForEach(destination.itinerary.sorted(by: { $0.index < $1.index }), id: \.self) { day in
                        EventView(day: day, city: destination.name)
                    }
                }
                .isHidden(destination.itinerary.count == 0)
                .cardStyle(.clear)
            }
        }
        .onChange(of: viewModel.itineraries) { oldValue, newValue in
            self.populateEvents(newValue)
        }
        .sheet(isPresented: $launchAllEvents) {
            AllEventsSelectionView(destination: destination)
        }
    }
}

extension _TabItineraryView {
    
    func updateTrip() {
        self.viewModel.generateItinerary(
            qType: .getDailyPlan(
                city: destination.name,
                dateRange: parseDateRange()
            )
        )
    }
    
    func parseDateRange() -> String {
        let dateRange = "\(destination.startDate.formatted(date: .long, time: .omitted)) and \(destination.endDate.formatted(date: .long, time: .omitted))"
        return dateRange
    }
    
    // Assign itinerary details from API to SWIFTData Persistent Cache
    func populateEvents(_ itineries: [DayItinerary]) {
        destination.itinerary = []
        for item in itineries {
            var events = [EventItem]()
            for event in item.activities {
                events.append(EventItem(
                    index: event.index,
                    title: event.title,
                    categories: event.categories
                ))
            }
            
            destination.itinerary.append(
                Itinerary(
                    index: item.index,
                    title: item.title,
                    date: item.date,
                    activities: events
                ))
        }
    }
}

