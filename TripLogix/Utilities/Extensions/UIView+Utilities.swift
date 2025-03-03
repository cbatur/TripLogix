
import SwiftUI

struct CardStyle: ViewModifier {
    let background: Color
    func body(content: Content) -> some View {
        content
            .background(background)
            .foregroundColor(.white)
            .font(.custom("Satoshi-Bold", size: 17))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 0.3)
            )
    }
}

extension View {
    func cardStyle(_ background: Color? = .gray.opacity(0.6)) -> some View {
        self.modifier(CardStyle(background: background ?? .gray.opacity(0.6)))
    }
}

struct CardStyleBordered: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct ButtonStylePrimary: ViewModifier {
    let style: TLButtonType
    func body(content: Content) -> some View {
        content
            .background(style.background)
            .foregroundColor(style.foreground)
            .font(.system(size: 15))
            .fontWeight(.medium)
            .clipShape(Capsule())
    }
}

extension View {
    func cardStyleBordered() -> some View {
        self.modifier(CardStyleBordered())
    }
    
    func buttonStylePrimary(_ style: TLButtonType = .primary) -> some View {
        self.modifier(ButtonStylePrimary(style: style))
    }
}

extension View {
    func shadowedStyle() -> some View {
        self
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
