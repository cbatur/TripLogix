
import SwiftUI

struct TripPlanView: View {
    @Bindable var destination: Destination
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()

    @State private var launchAllEvents = false
    @State private var isAnimating = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func shareButtonTapped() {
        // Share button tapped
        print("Share button tapped \(destination.id)")
    }
    
    var body: some View {
        VStack {
            if let alert = viewModel.activeAlertBox {
                AlertWithIconView(alertBox: alert)
                .cardStyle(.white)
            } else {
                VStack {
                    
                    VStack {
                        CityTitleHeader(cityName: destination.name)
                            .frame(alignment: .leading)
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("\(destination.startDate.formatted(date: .abbreviated, time: .omitted)) - \(destination.endDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.custom("Gilroy-Medium", size: 17))
                                .foregroundColor(.black) +
                            Text(dayDiffLabel())
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    
                    HStack {
                        Text("Update".uppercased())
                            .font(.custom("Gilroy-Bold", size: 15))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .cardStyle(.gray10)
                            .onTapGesture {
                                self.updateTrip()
                            }
                        Spacer()
                        Text("Personalize".uppercased())
                            .font(.custom("Gilroy-Bold", size: 15))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .cardStyle(.gray10)
                            .onTapGesture {
                                launchAllEvents = true
                            }
                    }
                    .padding()
                }
                .isHidden(!viewModel.showUpdateButton())
                
                Form {
                    ForEach(destination.itinerary.sorted(by: { $0.index < $1.index }), id: \.self) { day in
                        EventCardView(day: day, city: destination.name)
                    }
                }
                .isHidden(destination.itinerary.count == 0)
            }
            
            Spacer()
        }
        .navigationTitle("Trip Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareButtonTapped) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onChange(of: viewModel.itineraries) { _, newEvents in
            self.populateEvents(newEvents)
        }
        .sheet(isPresented: $launchAllEvents) {
            TripPlanEventCustomizeView(destination: destination)
        }
    }
}

extension TripPlanView {
    
    func dayDiff() -> Int {
        return daysBetween(start: destination.startDate, end: destination.endDate)
    }
    
    func dayDiffLabel() -> String {
        let ext = dayDiff() == 0 ? "day" : "days"
        return " (\(dayDiff()) \(ext))"
    }
    
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
                    categories: event.categories,
                    googlePlaceId: event.googlePlaceId
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
