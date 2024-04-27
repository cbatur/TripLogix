
import SwiftUI

struct TripPlanView: View {
    @Bindable var destination: Destination
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()
    @StateObject var cacheViewModel: CacheViewModel = CacheViewModel()
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible())]

    @State private var launchAllEvents = false
    @State private var isAnimating = false
    @State private var launchAdminTools = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func shareButtonTapped() {
        // Share button tapped
        launchAdminTools = true
        print("Share button tapped \(destination.id)")
    }
    
    var body: some View {
        
        VStack {
            if let alert = viewModel.activeAlertBox {
                
                AlertWithIconView(alertBox: alert)
                .cardStyle(.white)
                
            } else {
                
                VStack {
                    Divider()
                    LocationDateHeader(destination: destination)
                    Divider()
                    TripLinks()
                    Divider()
                }
                .isHidden(!viewModel.showUpdateButton())
                
                LazyVGrid(columns: columns) {
                    HStack {
                        Image(systemName: "text.redaction")
                            .padding(8)
                        Text("Create".uppercased())
                            .foregroundColor(Color.black)
                            .padding(.trailing, 6)
                            .fontWeight(.medium)
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                updateTrip()
                            }
                    }
                    .cardStyleBordered()
                    
                    if destination.allEventTags.count > 0 {
                        HStack {
                            Image(systemName: "person.2.badge.gearshape")
                                .padding(8)
                            Text("Personalize".uppercased())
                                .foregroundColor(Color.black)
                                .padding(.trailing, 6)
                                .fontWeight(.medium)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    self.launchAllEvents = true
                                }
                        }
                        .cardStyleBordered()
                    }

                    if destination.itinerary.count == 0 {
                        Text("A trip itinerary will be created for the dates you selected.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                        
                        if destination.allEventTags.count > 0 {
                            Text("Customize your trip to fit the activities you enjoy.")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                
                if destination.itinerary.count > 0 {
                    VStack {
                        HStack {
                            Text("Events and Activities")
                                .font(.system(size: 25)).bold()
                                .padding(.leading, 20)
                                .padding(.top, 13)
                            Spacer()
                        }
                        
                        Form {
                            ForEach(destination.itinerary.sorted(by: { $0.index < $1.index }), id: \.self) { day in
                                EventCardView(day: day, city: destination.name)
                            }
                        }
                    }
                    
                } else {
                    
                    VStack {
                        Image("empty_state_trip_events")
                            .resizable()
                            .scaledToFit()
                            .background(Color.clear)
                            .edgesIgnoringSafeArea(.all)
                        Text("No trip plan has been created yet.")
                            .font(.custom("Gilroy-Medium", size: 20))
                            .foregroundColor(Color.wbPinkMediumAlt)
                    }
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                    .frame(alignment: .center)
                }
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trip Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("navigation_logo_3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 28)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: shareButtonTapped) {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button(action: { updateTrip() }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onChange(of: viewModel.itineraries) {
            _,
            newEvents in
            self.populateEvents(newEvents)
            
            let c = CacheItem(
                name: "Itinerary Created - \(destination.id)",
                content: newEvents.map { $0.title }.joined(separator: ", ")
            )
            cacheViewModel.addCachedItem(c)
        }
        .sheet(isPresented: $launchAllEvents) {
            TripPlanEventCustomizeView(destination: destination)
        }
        .sheet(isPresented: $launchAdminTools) {
            AdminViewCachedLocations()
        }
        .onAppear {            
            if destination.allEventTags.count == 0 {
                self.viewModel.getCityEventCategories(
                    qType: .getEventCategories(
                        city: destination.name
                    )
                )
            }
        }
        .onChange(of: viewModel.allTags) { _, events in
            if events.count > 0 {
                destination.allEventTags = events
            }
        }
    }
}

extension TripPlanView {
    
    func updateTrip() {
        self.viewModel.generateItinerary(
            qType: .getDailyPlan(
                city: destination.name,
                dateRange: parseDateRange(),
                eventsExtension: eventsExtension()
            )
        )
    }
    
    func eventsExtension() -> String {
        return "Fetch events the following categories -> " + destination.selectedEventTags.joined(separator: ",")
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
        
        let c = CacheItem(
            name: "Itinerary Added to Destination - \(destination.id)",
            content: destination.itinerary.map { $0.title }.joined(separator: ", ")
        )
        cacheViewModel.addCachedItem(c)
        
    }
}
