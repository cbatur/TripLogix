
import SwiftUI

struct EventCardView: View {
    let day: Itinerary
    let city: String
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()
    
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
        Section(header: Text("\(viewModel.displayDailyDate(day.date)) - \(day.title)".uppercased())
            .foregroundColor(Color.wbPinkMediumAlt)
            .font(.custom("Satoshi-Bold", size: 14))) {
                
                ForEach(day.activities.sorted(by: { $0.index < $1.index }), id: \.self) { activity in
                    
                    if let place = viewModel.cachedGoogleLocations.filter({ place in
                        place.result.place_id == activity.googlePlaceId
                    }).first {
                        GooglePlaceCard(place)
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
                    }
                }
        }
        .onAppear {
            self.loadPlaces()
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
            HStack {
                VStack {
                    if let photoReference = place.result.photos.first?.photoReference {
                        let photoUrl = viewModel.urlForPhoto(reference: photoReference)
                        
                        RemoteIcon(with: photoUrl)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .edgesIgnoringSafeArea(.all)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .padding(4)
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Text("\(place.result.name)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(place.result.formattedAddress)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
        }
    }
}
