
import SwiftUI

struct NavigationBarIconView: View {
    let onAction: () -> Void
    let icon: String
    
    var body: some View {
        HStack {
            Button(action: {
                self.onAction()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 45, height: 45)
                    Image(systemName: icon)
                        .font(.system(size: 21)).bold()
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
    }
}
