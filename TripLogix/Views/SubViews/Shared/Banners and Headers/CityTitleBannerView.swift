
import SwiftUI

struct CityTitleBannerView: View {
    var cityName: String
    
    var body: some View {
        HStack {
            Image(cityName.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "") ?? "")
                .resizable()
                .frame(width: 26, height: 18)
            
            Text(cityName.split(separator: ",").map(String.init).first ?? "")
                .font(.custom("Satoshi-Regular", size: 25))
                .foregroundColor(Color.wbPinkShade) +
            Text(cityName.split(separator: ",").map(String.init).last ?? "")
                .font(.custom("Satoshi-Bold", size: 25))
                .foregroundColor(.white)
        }
        .padding(8)
        .cardStyle(.black.opacity(0.6))
    }
}

struct CityTitleHeader: View {
    var cityName: String
    
    var body: some View {
        HStack {
            Image(cityName.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "") ?? "")
                .resizable()
                .frame(width: 24, height: 17)
            
            Text(cityName)
                .font(.system(size: 21))
                .fontWeight(.medium)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
