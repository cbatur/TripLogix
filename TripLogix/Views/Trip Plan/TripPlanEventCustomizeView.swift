
import SwiftUI
import Combine

struct TripPlanEventCustomizeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Bindable var destination: Destination
    
    let eventColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 8), count: 3)
    
    @State var selectedTags: [String]
    let city: String

    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
        self.selectedTags = destination.selectedEventTags
        self.city = String(destination.name.split(separator: ",").first ?? "your destination")
    }
    
    func tagExists(_ tag: String) -> Bool {
        return selectedTags.contains(tag)
    }
    
    func tapTag(_ tag: String) {
        if tagExists(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
        
        destination.selectedEventTags = selectedTags
    }
    
    var body: some View {
        VStack {
            
            VStack {
                HStack {
                    Spacer()
                    Text("Save and Update")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(8)
                        .background(Color.tlOrange.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }

                    Image(systemName: "x.circle")
                        .font(.system(size: 23)).bold()
                        .foregroundColor(.gray)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(5)
                }
                .padding()
                
            }
            
//            LocationDateHeader(destination: destination, linksHidden: true)
//                .cardStyleBordered()
//                .padding()
            
            HStack {
                Text("Personalize Your \(city) Trip")
                    .font(.system(size: 25)).bold()
                    .foregroundColor(.gray3)
                
                Spacer()
            }
            .padding(.leading, 16)
            
            ScrollView {
                VStack {
                    Text("There are many activities to enjoy in \(city). Select your favorites from the various categories available.")
                        .font(.system(size: 14)).fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Rectangle()
                        .fill(Color.gray8)
                        .frame(height: 1)
                        .padding(.leading, 10)
                        .padding(.trailing, 60)
                    
                    LazyVGrid(columns: eventColumns) {
                        ForEach(destination.allEventTags, id: \.self) { tag in
                            Text(tag)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(tagExists(tag) ? Color.tlGreen : Color.gray)
                                .foregroundColor(.white)
                                .font(.system(size: 15)).fontWeight(tagExists(tag) ? .bold : .medium)
                                .clipShape(Capsule())
                                .onTapGesture {
                                    tapTag(tag)
                                }
                        }
                    }
                    .padding()
                }
            }

            Spacer()
        }
        
    }
}


//struct TripPlanEventCustomizeView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Bindable var destination: Destination
//    @StateObject var mockServices: MockServices = MockServices()
//    @StateObject var eventSelectionViewModel: EventSelectionViewModel = EventSelectionViewModel()
//    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
//
//    init(destination: Destination) {
//        _destination = Bindable(wrappedValue: destination)
//    }
//    
//    func parseDateRange() -> String {
//        let dateRange = "\(destination.startDate.formatted(date: .long, time: .omitted)) and \(destination.endDate.formatted(date: .long, time: .omitted))"
//        return dateRange
//    }
//    
//    var body: some View {
//        VStack {
//            VStack {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    
//                    VStack {
//                        CityTitleBannerView(cityName: destination.name)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    HStack {
//                        Image(systemName: "xmark.circle")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                }
//                
//                Text("Events and Activities")
//                    .foregroundColor(.wbPinkMedium)
//                    .font(.custom("Satoshi-Bold", size: 25))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding()
//            
//            Form {
//                if chatAPIViewModel.loadingMessage != nil {
//                    Text(chatAPIViewModel.loadingMessage ?? "")
//                        .foregroundColor(.red)
//                        .font(.headline).bold()
//                } else {
//                    ForEach(self.chatAPIViewModel.allEvents, id: \.self) { item in
//                        AllEventItem(viewModel: eventSelectionViewModel, item: item)
//                    }
//                }
//            }
//        }
//        .onAppear {
//            self.chatAPIViewModel.getChatGPTContent(qType: .getAllEvents(city: destination.name, dateRange: parseDateRange()), isMock: false)
//        }
//        
//    }
//}
//
//struct AllEventItem: View {
//    @ObservedObject var viewModel: EventSelectionViewModel
//    var item: EventCategory
//
//    var body: some View {
//        Section(header: HStack {
//            Text(item.category)
//                .font(.custom("Satoshi-Bold", size: 19))
//                .foregroundColor(.gray3)
//            Spacer()
//            Button(action: {
//                viewModel.toggleCategorySelection(item)
//            }) {
//                Image(systemName: viewModel.isCategorySelected(item) ? "checkmark.square" : "square")
//                    .font(.largeTitle)
//                    .foregroundColor(viewModel.isCategorySelected(item) ? Color.wbPinkMedium : .gray)
//            }
//        }) {
//            ForEach(item.events, id: \.self) { event in
//                Button(action: {
//                    viewModel.toggleEventSelection(event)
//                }) {
//                    HStack {
//                        
//                        DestinationIconView(image: Image("dublin"), size: 60)
//                        
//                        Text(event)
//                            .foregroundColor(viewModel.isEventSelected(event) ? .black : .black.opacity(0.6))
//                            .fontWeight(viewModel.isEventSelected(event) ? .bold : .regular)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .multilineTextAlignment(.leading)
//                        Spacer()
//                        Image(systemName: viewModel.isEventSelected(event) ? "checkmark.square" : "square")
//                            .font(.headline)
//                            .foregroundColor(viewModel.isCategorySelected(item) ? Color.wbPinkMedium : .gray)
//                    }
//                }
//            }
//        }
//    }
//}
//
//class EventSelectionViewModel: ObservableObject {
//    //@Bindable var destination: Destination
//    @Published var selectedEvents: Set<String> = []
//
////    init(destination: Destination) {
////        _destination = Bindable(wrappedValue: destination)
//////        guard let events = destination.allEvents else { return }
//////        selectedEvents = events
////    }
//    
//    // Assume `allEvents` is populated with your `AllEvents` data
//    //var allEvents: AllEvents = AllEvents(categories: [])
//
//    func isEventSelected(_ event: String) -> Bool {
//        selectedEvents.contains(event)
//    }
//
//    func toggleEventSelection(_ event: String) {
//        if selectedEvents.contains(event) {
//            selectedEvents.remove(event)
//        } else {
//            selectedEvents.insert(event)
//        }
//    }
//
//    func toggleCategorySelection(_ category: EventCategory) {
//        let categoryEvents = Set(category.events)
//        let selectedCategoryEvents = selectedEvents.intersection(categoryEvents)
//        if selectedCategoryEvents.count == categoryEvents.count {
//            // All events in category are selected, so unselect them
//            selectedEvents.subtract(categoryEvents)
//        } else {
//            // Not all events are selected, so select all
//            selectedEvents.formUnion(categoryEvents)
//        }
//    }
//
//    func isCategorySelected(_ category: EventCategory) -> Bool {
//        let categoryEvents = Set(category.events)
//        return !categoryEvents.isDisjoint(with: selectedEvents)
//    }
//    
//    func setAllEventsToDestination() {
//        //self.destination.allEvents = self.selectedEvents
//    }
//}
