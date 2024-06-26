
import SwiftUI

struct BannerWithDismiss: View {
    var dismiss: () -> Void
    var headline: String? = nil
    var subHeadline: String? = nil

    var body: some View {
        VStack {
            HStack {
                Color.wbPinkMediumAlt
                    .frame(width: 5)
                
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        HeaderHero(headline: headline ?? "")
                            .isHidden(headline == nil)
                        
                        Text(subHeadline ?? "")
                            .font(.custom("Gilroy-Regular", size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.headline)
                            .lineLimit(nil)
                            .isHidden(subHeadline == nil)
                    }
                    .padding(.top, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .padding()
        .padding(.top, 10)
        .frame(height: 120)
    }
}

struct HeaderHero: View {
    var headline: String

    var body: some View {
        Text(headline.uppercased())
            .font(.custom("Gilroy-Bold", size: 24))
            .foregroundColor(Color.wbPinkMediumAlt)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

