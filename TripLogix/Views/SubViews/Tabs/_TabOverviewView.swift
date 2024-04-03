
import SwiftUI

struct _TabOverviewView: View {
    @Bindable var destination: Destination
    @StateObject var placesViewModel: PlacesViewModel = PlacesViewModel()
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showDateChangeAlert = false
    @State private var showDatesSetAlert = false

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    var body: some View {
        VStack {
            // Content here
            FloatingMenuView()
            HorizontalExpandingMenu()
            
            VStack {
                Button(action: {
                    //self.dateEntryLaunched = false
                }) {
                    HStack {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    }
                }
    
                DatePicker("START DATE", selection: $startDate, in: Date()..., displayedComponents: .date)
                    .font(.custom("Satoshi-Bold", size: 15))
                    .padding(.leading, 15)
                    .foregroundColor(.gray)
                    .background(Color.gray10)
                    .cornerRadius(9)

                // End Date Picker
                DatePicker("END DATE", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .font(.custom("Satoshi-Bold", size: 15))
                    .padding(.leading, 15)
                    .foregroundColor(.gray)
                    .background(Color.gray10)
                    .cornerRadius(9)
                
                Button {
                    self.showDateChangeAlert = true
                } label: {
                    Text("UPDATE DATES")
                        .font(.custom("Bevellier-Regular", size: 24))
                        .padding(7)
                        .background(.white)
                        .foregroundColor(.wbPinkMedium)
                        .cornerRadius(5)
                }
                .frame(maxWidth: .infinity)
                .isHidden(dateRangeInvalid())
    
            }
            .padding()
            .cardStyle(.black.opacity(0.5))

        }
        .alert(self.alertUpdateTitle, isPresented: $showDateChangeAlert) {
            Button("Cancel", role: .cancel) {
                self.showDateChangeAlert = false
            }
            Button("OK") {
                self.showDateChangeAlert = false
                self.changeDatesAndReset()
            }
                } message: {
                    Text(self.alertUpdateMessage)
        }
        .alert("SUCCESS", isPresented: $showDatesSetAlert) {
            Button("OK") { }
                } message: {
                    Text("Your dates are set.")
        }
        .onChange(of: placesViewModel.places) { oldData, newData in
            self.handlePlaceImageChanged()
        }
        .onAppear {
            if destination.icon == nil {
                self.placesViewModel.reloadIcon(destination: destination)
            }
            
            self.startDate = destination.startDate
            self.endDate = destination.endDate
        }
    }
}

extension _TabOverviewView {
    
    func isSameDay() -> Bool {
        if Calendar.current.isDate(self.startDate, inSameDayAs: self.endDate) {
            return true
        } else {
            return false
        }
    }
    
    func handlePlaceImageChanged() {
        DispatchQueue.main.async { [self] in
            guard let icon = self.placesViewModel.places.randomElement()?.icon else { return }
            self.chatAPIViewModel.downloadImage(from: icon)
        }
    }
    
    var alertUpdateTitle: String {
        if destination.itinerary.count > 0 {
            return "Your itinerary will be removed and you will be asked to create a new itinerary for the following dates. \n\nContinue?"
        } else {
            return "Set these dates for your trip?"
        }
    }
    
    var alertUpdateMessage: String {
        return "\(DateFormatter.travelDate.string(from: self.startDate)) - \(DateFormatter.travelDate.string(from: self.endDate)) \n\n Total Days: \(daysBetween(start: self.startDate, end: self.endDate))"
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        return (Calendar.current.dateComponents([.day], from: start, to: end).day ?? -1) + 1
    }
    
    func changeDatesAndReset() {
        destination.startDate = startDate
        destination.endDate = endDate
        
        destination.itinerary = []
        showDatesSetAlert = true
    }
    
    func dateRangeInvalid() -> Bool {
        return ((self.startDate < Date()) && !isSameDay())
    }
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
