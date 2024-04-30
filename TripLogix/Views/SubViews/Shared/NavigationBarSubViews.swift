
import SwiftUI

struct NavigationBarSubViews: View {
    let onAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                self.onAction()
            }) {
                HStack {
                    Image(systemName: "list.bullet.circle.fill")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.wbPinkMedium)
                    Text("MY TRIPS")
                        .font(.custom("Bevellier-Regular", size: 22))
                        .foregroundColor(Color.wbPinkMediumAlt)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
            }
            Spacer()
        }
    }
}

struct NavigationBarIconView: View {
    let onAction: () -> Void
    let icon: String
    
    var body: some View {
        HStack {
            Button(action: {
                self.onAction()
            }) {
                Image(systemName: icon)
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 21)).bold()
                    .background(.clear)
                    .foregroundColor(Color.black)
            }
            Spacer()
        }
    }
}
