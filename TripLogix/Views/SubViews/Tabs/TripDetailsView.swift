
import SwiftUI
import SwiftData

struct TripDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    @StateObject var googlePlacesViewModel: GooglePlacesViewModel = GooglePlacesViewModel()
    @Bindable var destination: Destination
    let tabTripItems: [TabViews] = [.overview, .itinerary, .reservations]
    @State private var selectedTab: TabViews = .overview

    @State private var launchUpdateIconView = false
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
 
    @State private var showingImage = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DestinationBackgroundIconView(iconData: destination.icon)
                    .frame(width: geometry.size.width)
                    .scaleEffect(showingImage ? 1 : 0) // Start from invisible if not showing
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showingImage = true // Animate to full size when appearing
                        }
                    }
                    .onChange(of: chatAPIViewModel.imageData) { _, _ in
                        // Reset the animation state when the image changes
                        //withAnimation(.easeOut(duration: 0.1)) {
                            showingImage = false
                            showingImage = true
                        //}
                    }
                
                VStack {
                    VStack {
                        CityTitleBannerView(cityName: destination.name)
                            .frame(alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // TabView for trip tabs
                    LazyVGrid(columns: columns) {
                        ForEach(tabTripItems, id: \.self) { tab in
                            Text(tab.title.uppercased())
                                .font(.custom("Satoshi-Bold", size: 13))
                                .padding(7)
                                .background(
                                    self.selectedTab == tab ? Color.wbPinkMedium : Color.clear
                                )
                                .foregroundColor(
                                    self.selectedTab == tab ? Color.white : Color.black
                                )
                                .cornerRadius(5)
                                .onTapGesture {
                                    self.selectedTab = tab
                                }
                        }
                    }
                    .padding(7)
                    .cardStyle(.white)
                    
                    Spacer()
                    
                    VStack {
                        switch selectedTab {
                        case .overview:
                            _TabOverviewView(destination: destination)
                                .transition(.opacity)
                        case .reservations:
                            _TabReservationsView(destination: destination)
                                .transition(.opacity)
                        case .itinerary:
                            _TabItineraryView(destination: destination)
                                .transition(.opacity)
                        case .settings:
                            _TabTripSettings(destination: destination)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: selectedTab)
                }
                .frame(width: max(geometry.size.width - 20, 0))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            NavigationBarIconView(onAction: {
                self.presentationMode.wrappedValue.dismiss()
            })
        )
        .navigationBarItems(trailing:
            Button(action: {
                self.launchUpdateIconView = true
            }) {
                Image(systemName: "photo.circle.fill")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        )
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "TripDetailsView_Appear", params: tripDetailsViewAppearParams)
            
            if destination.icon == nil {
                self.googlePlacesViewModel.fetchPlaceDetails(placeId: destination.googlePlaceId ?? "")
            }
        }
        .onChange(of: self.googlePlacesViewModel.photosData) { oldData, newData in
            guard let photoURL = newData.first else { return }
            self.chatAPIViewModel.downloadImage(from: photoURL)
        }
        .onChange(of: chatAPIViewModel.imageData) { oldData, newData in
            destination.icon = newData
        }
        .sheet(isPresented: $launchUpdateIconView) {
            UpdateDestinationIcon(destination: destination)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Destination.self, configurations: config)
        let example = Destination(name: "Example Destination", details: "Example details go here and will automatically expand vertically as they are edited.")
        return TripDetailsView(destination: example)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
