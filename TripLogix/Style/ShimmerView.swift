
import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 0.8)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = UIScreen.main.bounds.width
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
}

struct SkeletonView: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .shimmer()
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .padding(.top, 4)
                    .shimmer()
            }
            .padding(.leading, 8)
        }
        .padding()
    }
}

struct PlaceholderItem: Identifiable {
    let id = UUID()
    static let placeholders = Array(repeating: PlaceholderItem(), count: 10)
}
