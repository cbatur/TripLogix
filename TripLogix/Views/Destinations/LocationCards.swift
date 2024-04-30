
import SwiftUI

struct LocationCardRecentSearch: View {
    var f: PlaceWithPhoto
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                if let imageData = f.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, alignment: .leading) 
                        .clipped()
                        .background(Color.gray)
                        .cornerRadius(8)
                } else {
                    Color.gray
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200)
                        .cornerRadius(8)
                }
                
                HStack {
                    Image(f.googlePlace.result.formattedAddress.description.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "") ?? "")
                        .resizable()
                        .frame(width: 27, height: 27)
                        .clipShape(Circle())
                    
                    Text("\(f.googlePlace.result.formattedAddress)")
                        .font(.custom("Gilroy-Medium", size: 17))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .cardStyle(.black.opacity(0.6))
            }
        }
        .padding(5)
    }
}
