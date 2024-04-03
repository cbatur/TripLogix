
import Foundation
import SwiftUI

enum TLButtonType {
    case primary
    case secondary
    case plain
    case green
    case orange
    case transDark
    
    var background: Color {
        switch self {
        case .primary:
            return Color.wbPinkMedium
        case .secondary:
            return Color.gray.opacity(0.03)
        case .plain:
            return Color.white
        case .green:
            return Color.tlGreen
        case .orange:
            return Color.tlOrange
        case .transDark:
            return Color.black.opacity(0.6)
        }
    }
    
    var foreground: Color {
        switch self {
        case .primary, .green, .orange:
            return Color.white
        case .secondary, .plain:
            return Color.gray
        case .transDark:
            return Color.white
        }
    }
}

struct TLButton: View {
    var title: String = ""
    var t: TLButtonType
    
    init(_ buttonType: TLButtonType, title: String) {
        t = buttonType
        self.title = title
    }
    
    var body: some View {
        Text(title.uppercased())
            .font(.custom("Gilroy-Bold", size: 18))
            .foregroundColor(t.foreground)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .cardStyle(t.background)
    }
}
