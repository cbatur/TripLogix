
import SwiftUI

struct TLCockpitTabView: View {
    @State private var selectedView = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedView) {
                CPDashboardView(selectedView: $selectedView)
                    .tabItem {
                        Image(systemName: "home")
                        Text("Home")
                    }
                    .tag(0)

                EmptyView()
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Charts")
                    }
                    .tag(1)

                EmptyView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Groom")
                    }
                    .tag(2)

                EmptyView()
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
