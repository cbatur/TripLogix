
import SwiftUI
import SwiftData

struct TripDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    @StateObject var googlePlacesViewModel: GooglePlacesViewModel = GooglePlacesViewModel()
    @Bindable var destination: Destination
    let tabTripItems: [TabViews] = [.overview, .itinerary, .reservations]
    @State private var selectedTab: TabViews = .overview
    @State private var heroImageOpacity: Double = 1.0
    @State private var launchDateSelection = false
    @State private var launchUpdateIconView = false
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
 
    @State private var showingImage = false
    
    func dayDiff() -> Int {
        return daysBetween(start: destination.startDate, end: destination.endDate)
    }
    
    func dayDiffLabel() -> String {
        let ext = dayDiff() == 0 ? "day" : "days"
        return " (\(dayDiff()) \(ext))"
    }
    
    func isSameDay() -> Bool {
        if dayDiff() > 0 {
            return false
        } else {
            return true
        }
    }
    
    func fetchDatesFromChild(startDate: Date, endDate: Date) {
        destination.startDate = startDate
        destination.endDate = endDate
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DestinationBackgroundIconView(iconData: destination.icon)
                    //.opacity(heroImageOpacity)
                    .frame(width: geometry.size.width)
                    .scaleEffect(showingImage ? 1 : 2) // Start from invisible if not showing
                    .onAppear {
//                        withAnimation(.easeOut(duration: 0.5)) {
//                            showingImage = true // Animate to full size when appearing
//                        }
                        withAnimation(.easeInOut(duration: 1)) {
                            showingImage = true
                            //self.heroImageOpacity = 0.1
                        }
                    }
                    .onChange(of: chatAPIViewModel.imageData) { _, _ in
                        // Reset the animation state when the image changes
                        //withAnimation(.easeOut(duration: 0.1)) {
                            //showingImage = false
                            showingImage = true
                        //}
                    }
                
                VStack {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text("\(destination.startDate.formatted(date: .abbreviated, time: .omitted)) - \(destination.endDate.formatted(date: .abbreviated, time: .omitted))") +
                        Text(dayDiffLabel())
                            .foregroundColor(.yellow)
                    }
                    .padding(9)
                    .cardStyle(.black.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        launchDateSelection = true
                    }
                    
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
                    .foregroundColor(Color.wbPinkMedium)
                    .font(.largeTitle)
            }
        )
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "TripDetailsView_Appear", params: tripDetailsViewAppearParams)
            
            if isSameDay() {
                launchDateSelection = true
            }
            
            if destination.icon == nil {
                self.googlePlacesViewModel.fetchPlaceDetails(placeId: destination.googlePlaceId)
            }
        }
        .sheet(isPresented: $launchDateSelection) {
            DateSelectionAlertView(
                startDate: destination.startDate,
                endDate: destination.endDate,
                passValidDates: fetchDatesFromChild
            )
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

struct DateSelectionAlertView: View {
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var displayStart = true

    var passValidDates: (Date, Date) -> Void

    @Environment(\.presentationMode) var presentationMode

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func datesAreValid() -> Bool {
        let diff = daysBetween(start: self.startDate, end: self.endDate)
        if diff > 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Spacer()

                    Text("SAVE")
                        .foregroundColor(Color.accentColor)
                        .fontWeight(.bold)
                        .onTapGesture {
                            dismiss()
                            passValidDates(startDate, endDate)
                        }
                        .isHidden(!datesAreValid())
                    Divider()
                    Text("Cancel")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            dismiss()
                        }

                }
                .padding()
                
                Divider()
                
                HStack {
                    Text("\(startDate.formatted(date: .abbreviated, time: .omitted))")
                        .padding(7)
                        .background(displayStart ? Color.wbPinkMedium : Color.clear)
                        .foregroundColor(displayStart ? Color.white : Color.black)
                        .cornerRadius(5)
                        .onTapGesture {
                            displayStart = true
                        }
                        
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                    Spacer()

                    Text("\(endDate.formatted(date: .abbreviated, time: .omitted))")
                        .padding(7)
                        .background(!displayStart ? Color.wbPinkMedium : Color.clear)
                        .foregroundColor(!displayStart ? Color.white : Color.black)
                        .cornerRadius(5)
                        .onTapGesture {
                            displayStart = false
                        }
                }
                
                Divider()
                
                VStack {
                    if displayStart {
                        DatePicker(
                            "Start Date",
                            selection: $startDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal, -10)
                        .transition(.move(edge: .leading))
                    } else {
                        DatePicker(
                            "End Date",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal, -10)
                        .transition(.move(edge: .trailing))
                    }
                }
                .animation(.default, value: displayStart) // Apply animation to the VStack
                
            }
            .padding()
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Destination.self, configurations: config)
//        let example = Destination(name: "Example Destination", details: "Example details go here and will automatically expand vertically as they are edited.")
//        return TripDetailsView(destination: example)
//            .modelContainer(container)
//    } catch {
//        fatalError("Failed to create model container")
//    }
//}
