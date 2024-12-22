
import SwiftUI
import Popovers

struct TripPlanView: View {
    @State private var selectedView = 0
    @Bindable var destination: Destination
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()
    @StateObject var cacheViewModel: CacheViewModel = CacheViewModel()

    @State private var launchAllEvents = false
    @State private var launchAdminTools = false
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        VStack {
            alertSection
            contentView
        }
        .onAppear {
            viewModel.fetchEventCategoriesIfNeeded(destination)
        }
        .onChange(of: viewModel.allTags) { _, events in
            if events.count > 0 {
                destination.allEventTags = events
            }
        }
        .onChange(of: viewModel.itineraries) { _, newEvents in
            self.viewModel.populateEvents(
                itineries: newEvents,
                destination: destination,
                cacheViewModel: cacheViewModel
            )
        }
        .sheet(isPresented: $launchAllEvents) {
            TripPlanEventCustomizeView(destination: destination)
        }
        .sheet(isPresented: $launchAdminTools) {
            AdminViewCachedLocations(selectedView: $selectedView)
        }
        .toolbar {
            navigationBarItems
        }
    }
    
    private var alertSection: some View {
        Group {
            if let alert = viewModel.activeAlertBox {
                AlertWithIconView(alertBox: alert)
                    .cardStyle(.white)
            }
        }
    }
    
    private var contentView: some View {
        VStack {
            if destination.itinerary.count == 0 {
                noEventsView
            } else {
                eventListView
            }
        }
    }

    private var eventListView: some View {
        VStack {
            HStack {
                Text("Events and Activities".uppercased())
                    .font(.system(size: 17)).bold()
                    .foregroundStyle(Color.wbPinkMedium)
                Spacer()
            }
            .padding(.bottom, 10)
            
            buttonSetView
            
            VStack {
                eventsAndActivitiesView
                    .isHidden(viewModel.activeAlertBox != nil)
            }
        }
    }
    
    private var createTripButton: some View {
        Button(action: { viewModel.updateTrip(destination) }) {
            if destination.itinerary.count == 0 {
                Label("Create", systemImage: "text.redaction")
                .padding(.horizontal, 15)
                .padding(9)
            } else {
                Image(systemName: "arrow.clockwise")
                    .padding(10)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStylePrimary(.pink)
    }

    private var personalizeButton: some View {
        VStack {
            if destination.allEventTags.count > 0 {
                Button(action: { launchAllEvents = true }) {
                    if destination.itinerary.count == 0 {
                        Label("Personalize", systemImage: "person.fill.viewfinder")
                            .padding(.horizontal, 15)
                            .padding(9)
                    } else {
                        Image(systemName: "person.fill.viewfinder")
                            .padding(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStylePrimary(.primary)
            } else {
                EmptyView()
            }
        }
    }
    
    private var buttonSetView: some View {
        VStack {
            HStack(spacing: 7) {
                Spacer()
                Button(action: {
                    launchAllEvents = true
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Personalize".uppercased())
                            .foregroundStyle(Color.gray4)
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.gray)
                    .padding(6)
                    .background(.white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray8, lineWidth: 1)
                    )
                }

                Button(action: {
                    viewModel.updateTrip(destination)
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Create New".uppercased())
                            .foregroundStyle(Color.gray4)
                            .font(.system(size: 14))
                            .fontWeight(.regular)
                    }
                    .foregroundColor(.gray)
                    .padding(6)
                    .background(.white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray8, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var navigationBarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            NavigationBarIconView(onAction: {
                shareButtonTapped()
            }, icon: "square.and.arrow.up")
        }
    }
    
    private func shareButtonTapped() {
        launchAdminTools = true
        print("Share button tapped \(destination.id)")
    }
    
    private var noEventsView: some View {
        VStack {
            Image("hero_create_trip")
                .resizable()
                .scaledToFit()
                .background(Color.clear)
                .edgesIgnoringSafeArea(.all)
                .frame(width: 120, height: 120) // Make dynamic based on screenSize later
            
            Text("Create a trip plan")
                .font(.custom("Gilroy-Bold", size: 23))
                .foregroundColor(Color.black)
                .padding(.bottom, 10)
            
            Text("A trip itinerary will be created for the dates you selected.")
                .font(.custom("Gilroy-Regular", size: 18))
                .foregroundColor(Color.gray3)
                .frame(alignment: .center)
            
            VStack {
                createTripButton
                personalizeButton
            }
            .padding(.leading, 35)
            .padding(.trailing, 35)
            .padding(.top, 20)
            .isHidden(viewModel.activeAlertBox != nil)
        }
        .padding(.top, 40)
    }
    
    private var eventsAndActivitiesView: some View {
        VStack {
            ForEach(destination.itinerary.sorted(by: { $0.index < $1.index }), id: \.self) { day in
                EventCardView(day: day, city: destination.name)
            }
        }
    }
}

struct ButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .foregroundColor(.black)
            .font(.system(size: 15, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeaderView: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 25)).bold()
                .padding(.leading, 20)
                .padding(.top, 13)
        }
    }
}
