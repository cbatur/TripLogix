
import SwiftUI

struct _TabOverviewView: View {
    @Bindable var destination: Destination
    @StateObject var placesViewModel: PlacesViewModel = PlacesViewModel()
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        VStack {
            // Content here
            HorizontalExpandingMenu()
        }
        .onChange(of: placesViewModel.places) { oldData, newData in
            self.handlePlaceImageChanged()
        }
        .onAppear {
            if destination.icon == nil {
                self.placesViewModel.reloadIcon(destination: destination)
            }
        }
    }
}

extension _TabOverviewView {
    
    func handlePlaceImageChanged() {
        DispatchQueue.main.async { [self] in
            guard let icon = self.placesViewModel.places.randomElement()?.icon else { return }
            self.chatAPIViewModel.downloadImage(from: icon)
        }
    }
    
//    var alertUpdateTitle: String {
//        if destination.itinerary.count > 0 {
//            return "Your itinerary will be removed and you will be asked to create a new itinerary for the following dates. \n\nContinue?"
//        } else {
//            return "Set these dates for your trip?"
//        }
//    }
    
}

struct HorizontalExpandingMenu: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            //Spacer()
            
            HStack {
                // Only show this button when the menu is not expanded
                if !isExpanded {
                    expandCollapseButton
                }
                
                if isExpanded {
                    // Expanded menu items
                    Button(action: {
                        // Action for Menu Item 1
                    }) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.blue))
                    }
                    
                    Button(action: {
                        // Action for Menu Item 2
                    }) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.green))
                    }
                    
                    Button(action: {
                        // Action for Menu Item 3
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.orange))
                    }
                    
                    expandCollapseButton
                }
            }
            .padding(.horizontal, isExpanded ? 20 : 0) // Add padding when expanded
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.5))
            .cornerRadius(30)
            .padding()
            .animation(.easeInOut, value: isExpanded)
        }
    }
    
    private var expandCollapseButton: some View {
        Button(action: {
            withAnimation {
                isExpanded.toggle()
            }
        }) {
            Image(systemName: isExpanded ? "xmark" : "plus")
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.red))
        }
    }
}

struct FloatingMenuView: View {
    @State private var showMenu = false

    var body: some View {
        VStack {
            Spacer()
            
            if showMenu {
                // Icons for menu items
                VStack {
                    Button(action: {
                        // Action for Menu Item 1
                    }) {
                        Image(systemName: "house.fill")
                            .padding()
                            .background(Circle().fill(Color.blue))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        // Action for Menu Item 2
                    }) {
                        Image(systemName: "person.fill")
                            .padding()
                            .background(Circle().fill(Color.green))
                            .foregroundColor(.white)
                    }
                }
                .transition(.scale) // Simple animation
            }
            
            // Floating Action Button
            Button(action: {
                withAnimation {
                    showMenu.toggle()
                }
            }) {
                Image(systemName: "plus")
                    .padding()
                    .background(Circle().fill(Color.red))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
        }
        .padding()
    }
}
