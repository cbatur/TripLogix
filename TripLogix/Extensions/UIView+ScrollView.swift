
import SwiftUI

extension View {
    func previewHeaderContent() -> some View {
        self.foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
    }
}
