
import SwiftUI

struct ImageAnimate: View {
    @State private var itemPositions: [CGPoint] = [CGPoint(x: 100, y: 600), CGPoint(x: 200, y: 600), CGPoint(x: 300, y: 600)]
    @State private var luggageOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Image("icon_luggage_alt")
                .resizable()
                .frame(width: 120, height: 120)
                .offset(y: luggageOffset)

            // Items to throw in the luggage
            ForEach(0..<itemPositions.count, id: \.self) { index in
                Image(systemName: "iphone") // Replace this with your item view
                    .frame(width: 50, height: 50)
                    .position(itemPositions[index])
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 1)) {
                            itemPositions[index] = CGPoint(x: 150, y: 400) // Adjust final position based on luggage location
                        }
                    }
            }
        }
        .onAppear {
            // Animate luggage appearance
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                luggageOffset = 20 // Slight move to indicate where to throw items
            }
        }
    }
}
