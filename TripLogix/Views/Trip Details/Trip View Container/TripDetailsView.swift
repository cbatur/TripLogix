
import SwiftUI
import SwiftData

struct TripDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var googlePlacesViewModel: GooglePlacesViewModel = GooglePlacesViewModel()
    @StateObject var ssFlightsViewModel: SSFlightsViewModel = SSFlightsViewModel()
    @Bindable var destination: Destination
    
    @State private var selectedIndex = 0
    @State private var launchDateSelection = false
    @State private var launchUpdateIconView = false
    let tripLinks: [TripLink] = [.events, .flights, .hotels, .rentals, .docs]

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        VStack {
            tripDetails
            
            TabView(selection: $selectedIndex) {
                switch selectedIndex {
                case 0:
                    TripPlanView(destination: destination)
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
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            NavigationBarIconView(onAction: {
                self.presentationMode.wrappedValue.dismiss()
            }, icon: "arrow.left")
        )
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
        .sheet(isPresented: $launchUpdateIconView) {
            UpdateDestinationIcon(destination: destination)
        }
    }
    
    private var tripDetails: some View {
        VStack {
            Divider()
            LocationDateHeader(
                destination: destination,
                passDateClick: fetchDateLinkFromHeader,
                passIconClick: fetchIconClickFromHeader
            )
            VStack {
                Divider()
                TripLinks(passSelectedIndex: changeTabs)
                Divider()
            }
        }
    }
    
//    private var navigationBarItems: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            Button(action: shareButtonTapped) {
//                Image(systemName: "square.and.arrow.up")
//            }
//        }
//    }
}

extension TripDetailsView {
    
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
