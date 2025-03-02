
import SwiftUI

struct TLTabView: View {
    @State private var selectedView = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedView) {
                TripsView(selectedView: $selectedView)
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Trips")
                    }
                    .tag(0)

                AdminViewCachedLocations(selectedView: $selectedView)
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Alerts")
                    }
                    .tag(1)

                EmptyView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Test")
                    }
                    .tag(2)

                SessionCheckView(selectedView: $selectedView)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Account")
                    }
                    .tag(3)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
