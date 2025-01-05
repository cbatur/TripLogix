import SwiftUI

struct GooglePlaceCard: View {
    @StateObject var viewModel: EventViewModel = EventViewModel()
    let place: GooglePlace
    
    init(_ place: GooglePlace) {
        self.place = place
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    if let photoUrl = viewModel.photosFromDatabase?.photos.first?.imageUrl,
                       let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .padding(4)
                            case .failure:
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .foregroundColor(.gray)
                                    .padding(4)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .foregroundColor(.gray)
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
        .onAppear {
            Task {
                await viewModel.fetchPhotosById(placeId: place.result.place_id)
            }
        }
    }
}
