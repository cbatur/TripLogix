
import SwiftUI
import SwiftData
import ScalingHeaderScrollView

struct ContentView: View {
    @StateObject var viewModel: EventViewModel = EventViewModel()

    func loadPlaces() {
        viewModel.getCachedGooglelocations()
    }
    
    // Move real ones here
    @StateObject var placesViewModel: PlacesViewModel = PlacesViewModel()
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    @StateObject var googlePlacesViewModel: GooglePlacesViewModel = GooglePlacesViewModel()

    @Bindable var destination: Destination
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func loadPhotodByGooglePlacesId() {
        //self.googlePlacesViewModel.fetchPlaceDetails(placeId: destination.googlePlaceId)
    }

    var body: some View {
        
        ScalingHeaderScrollView {
             ZStack {
                 Rectangle()
                     .fill(.gray.opacity(0.15))
                 //Image("raindance")
                 DestinationIconDataView(iconData: destination.icon)
             }
         } content: {
             pageContent
             Text("↓ Pull to refresh ↓")
                 .multilineTextAlignment(.center)
                 .padding()
         }
         .onChange(of: googlePlacesViewModel.photosData) { _, photoArray in
             guard photoArray.count > 0, let photo = photoArray.first else { return }
             self.chatAPIViewModel.downloadImage(from: photo)
         }
         .onChange(of: chatAPIViewModel.imageData) { oldData, newData in
             destination.icon = newData
         }
         .onAppear {
             self.loadPlaces()

             if destination.icon == nil {
                 self.loadPhotodByGooglePlacesId()
             }
         }
        
    }
    
    private var pageContent: some View {
        VStack {
            
            Text("Some Header")
            .padding(7)
            .cardStyleBordered()
            
            VStack {
                ForEach(Array(viewModel.cachedGoogleLocations.reversed().enumerated()), id: \.element) { index, place in
                    VStack {
                        Text("\(index + 1) - \(place.result.name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(place.result.formattedAddress)
                            .foregroundColor(.gray)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
    }
}
