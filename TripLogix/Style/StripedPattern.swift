
import SwiftUI

struct StripedPattern: View {
    var body: some View {
        GeometryReader { geometry in
            let stripeWidth = geometry.size.width / 120 // Increase the stripe count to make them thinner
            let stripeCount = Int(geometry.size.width / stripeWidth)
            
            HStack(spacing: 0) {
                ForEach(0..<stripeCount, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Color.white : Color.clear)
                        .frame(width: stripeWidth)
                }
            }
        }
    }
}
