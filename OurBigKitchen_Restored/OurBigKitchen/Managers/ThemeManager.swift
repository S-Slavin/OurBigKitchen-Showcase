import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode = false
    @Published var primaryColor: Color = .blue
    @Published var accentColor: Color = .orange
    
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let accent = Color.orange
        static let background = Color.white
        static let mealsServed = Color.green
        static let donations = Color.purple
        static let wasteReduced = Color.yellow
        static let hoursContributed = Color.blue
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct ShadowStyle {
        static let small = Shadow(radius: 2, x: 0, y: 1)
        static let medium = Shadow(radius: 4, x: 0, y: 2)
        static let large = Shadow(radius: 8, x: 0, y: 4)
    }
    
    func setDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
    }
    
    func setPrimaryColor(_ color: Color) {
        primaryColor = color
    }
    
    func setAccentColor(_ color: Color) {
        accentColor = color
    }
} 