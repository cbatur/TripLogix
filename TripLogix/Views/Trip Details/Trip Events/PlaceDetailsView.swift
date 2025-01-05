import SwiftUI
import UIKit

struct PlaceDetailsView: View {
    @Binding var googlePlaceId: String
    @StateObject var viewModel: EventViewModel = EventViewModel()
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
    @StateObject var viewModel: EventViewModel = EventViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Place Name
                Text("\(place.result.name) - \(viewModel.photosFromDatabase?.photos.count ?? 0)")
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

                // Photo ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        VStack(spacing: 10) {
                            if let photosResponse = viewModel.photosFromDatabase, !photosResponse.photos.isEmpty {
                                PlaceDetailsContentView.renderPhotoRow(
                                    photos: photosResponse.photos,
                                    filter: { $0.0 % 2 == 0 } // Even-indexed photos
                                )
                                PlaceDetailsContentView.renderPhotoRow(
                                    photos: photosResponse.photos,
                                    filter: { $0.0 % 2 != 0 } // Odd-indexed photos
                                )
                            } else {
                                Text("No photos available")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                await viewModel.fetchPhotosById(placeId: place.result.place_id)
            }
        }
        .navigationTitle("Place Details")
        .navigationBarTitleDisplayMode(.inline)
    }

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

    // Static helper method for rendering photo rows
    static func renderPhotoRow(photos: [Photo], filter: @escaping ((Int, Photo)) -> Bool) -> some View {
        HStack(spacing: 10) {
            ForEach(photos.enumerated().filter { filter($0) }.map { $0.1 }, id: \.id) { photo in
                if let localFilePath = photo.localFilePath,
                   let uiImage = UIImage(contentsOfFile: localFilePath) {
                    // Use cached image
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 150)
                        .clipped()
                        .cornerRadius(8)
                } else if let imageUrl = URL(string: photo.imageUrl) {
                    // Fallback to API URL if no cached image
                    AsyncImage(url: imageUrl) { phase in
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
                } else {
                    // Default placeholder if neither is available
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 150)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
