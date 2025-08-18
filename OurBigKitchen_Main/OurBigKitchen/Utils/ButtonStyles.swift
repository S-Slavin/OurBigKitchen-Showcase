import SwiftUI

// MARK: - Button Styles

struct ButtonStyles {
    static var springy: SpringyButtonStyle { SpringyButtonStyle() }
    static var scale: ScaleButtonStyle { ScaleButtonStyle() }
    static var bouncy: BouncyButtonStyle { BouncyButtonStyle() }
}

struct SpringyButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Modifiers

struct GradientBackground: ViewModifier {
    var startColor: Color
    var endColor: Color
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    init(
        startColor: Color = Color.accentColor.opacity(0.8),
        endColor: Color = Color.accentColor,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.startColor = startColor
        self.endColor = endColor
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [startColor, endColor]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
    }
}

extension View {
    func gradientBackground(
        startColor: Color = Color.accentColor.opacity(0.8),
        endColor: Color = Color.accentColor,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> some View {
        self.modifier(GradientBackground(
            startColor: startColor,
            endColor: endColor,
            startPoint: startPoint,
            endPoint: endPoint
        ))
    }
} 
