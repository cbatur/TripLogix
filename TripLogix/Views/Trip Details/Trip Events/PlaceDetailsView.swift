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

                if let phoneNumber = place.result.formattedPhoneNumber {
                    Text("\(phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            callPhoneNumber(phoneNumber: phoneNumber)
                        }
                }

                if let rating = place.result.rating {
                    Text("\(String(format: "%.1f", rating)) ⭐⭐⭐⭐⭐ (\(place.result.userRatingsTotal ?? 0))")
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        VStack(spacing: 10) {
                            // First row
                            if let photos = place.result.photos?.enumerated().filter({ $0.offset % 2 == 0 }).map({ $0.element }) {
                                HStack(spacing: 10) {
                                    ForEach(photos, id: \.photoReference) { photo in
                                        AsyncImage(
                                            url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo.photoReference)&key=\(decryptAPIKey(.googlePlaces) ?? "")")
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

                            // Second row
                            if let photos = place.result.photos?.enumerated().filter({ $0.offset % 2 != 0 }).map({ $0.element }) {
                                HStack(spacing: 10) {
                                    ForEach(photos, id: \.photoReference) { photo in
                                        AsyncImage(
                                            url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo.photoReference)&key=\(decryptAPIKey(.googlePlaces) ?? "")")
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
                }
                
                Text("The extra description text will come here from ChatGPT API")
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
