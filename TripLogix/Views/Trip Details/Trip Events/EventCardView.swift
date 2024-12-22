
import SwiftUI

struct EventCardView: View {
    let day: Itinerary
    let city: String
    
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()
    @State var showLocationDetailsModal = false
    @State var googlePlaceId: String = ""
    
    init(day: Itinerary, city: String) {
        self.day = day
        self.city = city
    }
    
    func loadPlaces() {
        // Add to Google place cache If it doesn't exist.
        for activity in day.activities {
            if !viewModel.cachedGoogleLocations.contains(where: { $0.result.place_id == activity.googlePlaceId }) {
                viewModel.addSingleGooglePlace(activity.googlePlaceId)
            }
        }
        
        // Get all cached Google Places
        viewModel.getCachedGooglelocations()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.displayDailyDate(day.date)) - \(day.title)".uppercased())
                    .font(.system(size: 14)).bold()
                    .foregroundStyle(Color.slSofiColor)
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.top, 20)
            
            VStack {
                ForEach(day.activities.sorted(by: { $0.index < $1.index }), id: \.self) { activity in
                    
                    if let place = viewModel.cachedGoogleLocations.filter({ place in
                        place.result.place_id == activity.googlePlaceId
                    }).first {
                        GooglePlaceCard(place)
                            .onTapGesture {
                                showLocationDetailsModal = true
                                googlePlaceId = place.result.place_id
                            }
                        Divider()
                    } else {
                        
                        HStack(alignment: .center) {
                            Image(systemName: activity.categories.count > 0 ?
                                  Icon(rawValue: activity.categories.first ?? "dot.square")?.system ?? "dot.square" :
                                    "dot.square")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(alignment: .center)
                            
                            Text("\(activity.title)")
                                .foregroundColor(.black.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 8)
                        Divider()
                    }
                }
                
            }
            .padding()
            .cardStyle(.white)
        }
        .onAppear {
            self.loadPlaces()
        }
        .sheet(isPresented: $showLocationDetailsModal) {
            PlaceDetailsView(googlePlaceId: $googlePlaceId)
        }
    }
}

struct GooglePlaceCard: View {
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()
    let place: GooglePlace
    
    init(_ place: GooglePlace) {
        self.place = place
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) { // Align to the top to handle multiple lines
                VStack {
                    if let photoReference = place.result.photos?.first?.photoReference {
                        let photoUrl = viewModel.urlForPhoto(reference: photoReference)
                        
                        RemoteIcon(with: photoUrl)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .padding(4)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("\(place.result.name)")
                        .font(.system(size: 15))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 1)
                    
                    Text("\(place.result.formattedAddress)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer() 
            }
        }
    }
}
