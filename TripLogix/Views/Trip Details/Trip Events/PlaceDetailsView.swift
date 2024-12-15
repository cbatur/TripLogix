import SwiftUI
import UIKit

struct PlaceDetailsView: View {
    @Binding var googlePlaceId: String
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()
    @State var googlePlace: GooglePlace?

    var body: some View {
        VStack {
            if let place = googlePlace {
                PlaceDetailsContentView(place: place)
            } else {
                Text("Loading...")
                    .foregroundStyle(.black)
            }
        }
        .onAppear {
            viewModel.getCachedGooglelocations()
            
            if let place = viewModel.cachedGoogleLocations.filter({ place in
                place.result.place_id == googlePlaceId
            }).first {
                googlePlace = place
            } else {
                viewModel.cacheSingleGoogleLocation(googlePlaceId)
            }
        }
    }

}

struct PlaceDetailsContentView: View {
    @State var place: GooglePlace
    @StateObject var viewModel: TripPlanViewModel = TripPlanViewModel()

    func callPhoneNumber(phoneNumber: String) {
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Cannot make a phone call.")
        }
    }
    
    func openGoogleMaps(latitude: Double, longitude: Double, zoom: Int = 14) {
        let googleMapsURL = "comgooglemaps://?q=\(latitude),\(longitude)&zoom=\(zoom)"
        
        if let url = URL(string: googleMapsURL),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let webURL = "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)"
            if let url = URL(string: webURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Place Name
                Text(place.result.name)
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .fontWeight(.regular)
                    .padding(.top)

                Text("\(place.result.formattedAddress)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        openGoogleMaps(latitude: place.result.geometry.location.lat, longitude: place.result.geometry.location.lng)
                    }

                Text("\(place.result.formattedPhoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        callPhoneNumber(phoneNumber: "\(place.result.formattedPhoneNumber)")
                    }

                // Rating and Reviews
                HStack {
                    Text("\(String(format: "%.1f", place.result.rating)) ⭐⭐⭐⭐⭐ (\(place.result.userRatingsTotal))")
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                }

                // Opening Hours
//                if let weekdayText = place.currentOpeningHours?.weekdayText {
//                    VStack(alignment: .leading) {
//                        Text("🕒 Opening Hours:")
//                            .font(.headline)
//                        ForEach(weekdayText, id: \.self) { day in
//                            Text(day)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }

                // Photos
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        VStack(spacing: 10) {
                            // First row
                            HStack(spacing: 10) {
                                ForEach(place.result.photos.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }, id: \.photoReference) { photo in
                                    AsyncImage(
                                        url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo.photoReference)&key=D2YUct4ewe7M")
                                    ) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 200, height: 150)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 150)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .failure:
                                            Image(systemName: "photo.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 200, height: 150)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                            
                            // Second row
                            HStack(spacing: 10) {
                                ForEach(place.result.photos.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }, id: \.photoReference) { photo in
                                    AsyncImage(
                                        url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo.photoReference)&key=D2YUct4ewe7M")
                                    ) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 200, height: 150)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 150)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .failure:
                                            Image(systemName: "photo.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 200, height: 150)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Text("Sala Gold Málaga is more than just a nightclub—it’s an immersive nightlife experience that pulses with the soul of Málaga. Nestled in the city’s vibrant core, this hotspot is where the rhythm of the coast meets the energy of a cosmopolitan crowd. From the moment you step inside, you’re swept into a world of shimmering gold decor, cutting-edge light displays, and a palpable buzz that feels like the heartbeat of the city itself. \n\nThe ambiance is magnetic, effortlessly blending sophistication with an edge of playfulness. Picture a dance floor that glows under a kaleidoscope of lights, where beats shift seamlessly from sultry Latin grooves to electrifying house anthems. The music isn’t just heard—it’s felt, reverberating through the walls and into your chest, pulling you deeper into the moment. Local and international DJs curate sets that tell stories, transforming the night into something unforgettable./n/nWhat truly sets Sala Gold apart is its personal touch. The bartenders aren’t just mixing drinks—they’re crafting experiences, serving signature cocktails with a flair that mirrors the energy of the room. Whether you’re perched at the bar sipping a custom creation or tucked away in a VIP booth surrounded by your crew, every corner of Sala Gold is designed to make you feel like you’ve stepped into a night that belongs only to you./n/nIt’s not just a place to party—it’s a place to connect, to revel in the spontaneity of the night, and to let loose without inhibition. Sala Gold isn’t just part of Málaga’s nightlife scene—it defines it. For those who crave the extraordinary, this is where the night comes alive, glittering with the promise of stories to tell the next day.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                //}

                // Reviews
//                if let reviews = place.reviews, !reviews.isEmpty {
//                    Text("📝 Reviews:")
//                        .font(.headline)
//                        .padding(.top)
//                    ForEach(reviews, id: \.authorName) { review in
//                        VStack(alignment: .leading, spacing: 8) {
//                            HStack {
//                                if let profilePhotoURL = review.profilePhotoURL {
//                                    AsyncImage(url: URL(string: profilePhotoURL)) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                    } placeholder: {
//                                        Circle().fill(Color.gray)
//                                    }
//                                    .frame(width: 40, height: 40)
//                                    .clipShape(Circle())
//                                }
//                                Text(review.authorName ?? "Anonymous")
//                                    .font(.headline)
//                            }
//                            if let text = review.text {
//                                Text(text)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            Divider()
//                        }
//                    }
//                }
            }
            .padding()
        }
        .navigationTitle("Place Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
