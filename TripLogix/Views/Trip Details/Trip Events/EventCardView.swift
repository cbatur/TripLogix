
import SwiftUI

struct EventCardView: View {
    let day: Itinerary
    let city: String
    
    @StateObject var viewModel: EventViewModel = EventViewModel()
    @State var showLocationDetailsModal = false
    @State var googlePlaceId: String = ""
    
    init(day: Itinerary, city: String) {
        self.day = day
        self.city = city
    }
    
    func loadPlaces() {
        // Get all cached Google Places
        viewModel.getCachedGooglelocations()
        
        // Add to Google place cache If it doesn't exist.
        for activity in day.activities {
            if !viewModel.cachedGoogleLocations.contains(where: { $0.result.place_id == activity.googlePlaceId }) {
                if !activity.googlePlaceId.isEmpty { viewModel.addSingleGooglePlace(activity.googlePlaceId)
                }
            }
        }
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
