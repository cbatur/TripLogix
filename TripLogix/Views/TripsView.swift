
import SwiftUI
import SwiftData

struct MainTabbedView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    
    var body: some View {
        ZStack{
            
            TabView(selection: $selectedSideMenuTab) {
                AccountView(presentSideMenu: $presentSideMenu)
                    .tag(0)
                AccountView(presentSideMenu: $presentSideMenu)
                    .tag(1)
                AccountView(presentSideMenu: $presentSideMenu)
                    .tag(2)
                AccountView(presentSideMenu: $presentSideMenu)
                    .tag(3)
            }
            
            SideMenu(
                isShowing: $presentSideMenu,
                content: AnyView(
                    SideMenuView(
                        selectedSideMenuTab: $selectedSideMenuTab,
                        presentSideMenu: $presentSideMenu
                    )
                )
            )
        }
    }
}

struct TripsView: View {
    @Binding var selectedView: Int
    
    @Environment(\.modelContext) var modelContext
    @State private var path = [Destination]()
    @State private var sortOrder = SortDescriptor(\Destination.startDate)
    @State private var launchNewDestination = false
    @State var dataFromChild: (GooglePlace?)
    @State var launchLoginView = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                DestinationListingView(sort: sortOrder, searchString: "")
                    .isHidden(self.path.count > 0)
                
                AddDestinationButton()
                    .onTapGesture {
                        self.launchNewDestination = true
                    }
            }
            //.navigationTitle("My Trips".uppercased())
            .navigationDestination(for: Destination.self, destination: TripDetailsView.init)
            .sheet(isPresented: $launchNewDestination) {
                AddNewDestinationView { data in
                    self.dataFromChild = data                    
                }
            }
            .onChange(of: self.dataFromChild) { _, place in
                guard let place = place else { return }
                self.addDestination(place: place)
            }
            .toolbar {
                navigationBarItems
            }
            .navigationBarItems(leading:
                Button{
                    //presentSideMenu.toggle()
                } label: {
                    Image("menu")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
            )
        }
        .analyticsScreen(name: "TripsView")
//        .sheet(isPresented: $launchLoginView) {
//            SessionCheckView()
//        }
        .onAppear{
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "TL12345"
            AnalyticsManager.shared.logEvent(name: "TripsView_Appear")
            AnalyticsManager.shared.setUserId(userId: deviceId)
            AnalyticsManager.shared.setUserProperty(value: true.description, property: "test_user")
        }
        .onDisappear{
            AnalyticsManager.shared.logEvent(name: "TripsView_Disappear")
        }
    }
    
    private var navigationBarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Image(systemName: "person.circle")
                .font(.system(size: 27))
                .onTapGesture {
                    //launchLoginView = true
                    selectedView = 3
                }
        }
    }
    
    func addDestination(place: GooglePlace) {
        let destination = Destination(name: place.result.formattedAddress.sanitizeLocation())
        destination.googlePlaceId = place.result.place_id
        destination.startDate = Date.daysFromToday(1)
        destination.endDate = Date.daysFromToday(3)
        modelContext.insert(destination)
        //path = [destination]
    }
}
