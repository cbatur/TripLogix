
import SwiftUI
import SwiftData
import ScrollKit

struct TripDetailsView: View {
    var defaultBanner: Image = Image("destination_placeholder")
    @StateObject var googlePlacesViewModel: GooglePlacesViewModel = GooglePlacesViewModel()
    @StateObject var ssFlightsViewModel: SSFlightsViewModel = SSFlightsViewModel()
    @State private var launchDateSelection = false
    
    @Bindable var destination: Destination
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        TripDetailsViewFeed(destination: destination, headerView: {
            ZStack {
                ScrollViewHeaderImage(setImage())
                StripedPattern()
                    .opacity(0.1)
                ScrollViewHeaderGradient(.black.opacity(0.2), .black.opacity(0.8))
            }
        }, headerHeight: 150)
        .onAppear {
            
            AnalyticsManager.shared.logEvent(name: "TripDetailsView_Appear", params: tripDetailsViewAppearParams)

            if isSameDay() {
                launchDateSelection = true
            }
            
            if destination.icon == nil {
                self.googlePlacesViewModel.fetchPlaceDetails(placeId: destination.googlePlaceId)
            }
            
            ssFlightsViewModel.queryAirport(destination.baseCity)
        }
        .sheet(isPresented: $launchDateSelection) {
            DateSelectionAlertView(
                startDate: destination.startDate,
                endDate: destination.endDate,
                passValidDates: fetchDatesFromChild
            )
        }
    }

    func setImage() -> Image {
        if let iconData = destination.icon, let uiImage = UIImage(data: iconData) {
            return Image(uiImage: uiImage)
        } else {
            return Image("destination_placeholder")
        }
    }
}

struct TripDetailsViewFeed<HeaderView: View>: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Bindable var destination: Destination
    
    @State private var selectedIndex = 0
    @State private var launchDateSelection = false
    @State private var launchUpdateIconView = false
    let tripLinks: [TripLink] = [.events, .flights, .hotels, .rentals, .docs]
    
    init(destination: Destination, @ViewBuilder headerView: @escaping () -> HeaderView, headerHeight: CGFloat = 150) {
        _destination = Bindable(wrappedValue: destination)
        self.headerView = headerView
        self.headerHeight = headerHeight
    }
    
    let headerHeight: CGFloat
    @ViewBuilder
    let headerView: () -> HeaderView

    @State
    private var headerVisibleRatio: CGFloat = 1

    @State
    private var scrollOffset: CGPoint = .zero
    
    var body: some View {
        ZStack {
            VStack {
                ScrollViewWithStickyHeader(
                    header: header,
                    headerHeight: 150,
                    onScroll: handleScrollOffset
                ) {
                    tripDetails
                        .background(Color.slBack1)
                    
                    switch selectedIndex {
                    case 0:
                        TripPlanView(destination: destination)
                            .padding()
                    case 1:
                        FlightsHomeView(destination: destination)
                    case 2:
                        HotelsHomeView()
                    case 3:
                        RentalsHomeView()
                    case 4:
                        DocumentsView()
                    default:
                        TripPlanView(destination: destination)
                    }
                }
                .padding(.bottom, 1)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        CityTitleHeader(cityName: destination.name)
                        DestinationIconDataView(iconData: destination.icon, size: 34)
                        Spacer()
                    }
                    .previewHeaderContent()
                    .opacity(1 - headerVisibleRatio)
                }
            }
            .background(Color.slBack1)
            .toolbarBackground(.hidden)
            .statusBarHidden(scrollOffset.y > -3)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                NavigationBarIconView(onAction: {
                    self.presentationMode.wrappedValue.dismiss()
                }, icon: "arrow.left")
            )
            .sheet(isPresented: $launchUpdateIconView) {
                UpdateDestinationIcon(destination: destination)
            }
        }
    }
    
    func header() -> some View {
        ZStack(alignment: .bottomLeading) {
            headerView()
            ScrollViewHeaderGradient()
            headerTitle.previewHeaderContent()
        }
    }

    private var tripDetails: some View {
        TripLinks(passSelectedIndex: changeTabs)
    }
    
    var headerTitle: some View {
        VStack {
            LocationDateHeader(
                destination: destination,
                passDateClick: fetchDateLinkFromHeader,
                passIconClick: fetchIconClickFromHeader
            )
        }
        .opacity(headerVisibleRatio)
    }
    
    func handleScrollOffset(_ offset: CGPoint, headerVisibleRatio: CGFloat) {
        self.scrollOffset = offset
        self.headerVisibleRatio = headerVisibleRatio
    }
    
}

extension TripDetailsView {
    
    func fetchDatesFromChild(startDate: Date, endDate: Date) {
        destination.startDate = startDate
        destination.endDate = endDate
    }
    
    func fetchDateLinkFromHeader() {
        launchDateSelection = true
    }
    
//    func fetchIconClickFromHeader() {
//        self.launchUpdateIconView = true
//    }
    
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
    
    private func shareButtonTapped() {
        print("Share button tapped \(destination.id)")
    }
}

extension TripDetailsViewFeed {
    
    func changeTabs(_ index: Int) {
        self.selectedIndex = index
    }
    
    func fetchDatesFromChild(startDate: Date, endDate: Date) {
        destination.startDate = startDate
        destination.endDate = endDate
    }
    
    func fetchDateLinkFromHeader() {
        launchDateSelection = true
    }
    
    func fetchIconClickFromHeader() {
        self.launchUpdateIconView = true
    }
    
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
    
    private func shareButtonTapped() {
        print("Share button tapped \(destination.id)")
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
            Spacer()
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
                .animation(.default, value: displayStart)
                
            }
            .padding()
        }
        .presentationDetents([.height(650)])
        .interactiveDismissDisabled()
    }
}
