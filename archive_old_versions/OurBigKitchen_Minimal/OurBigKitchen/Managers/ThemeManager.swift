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
        static let cardBackground = Color(.systemBackground)
        static let mealsServed = Color.green
        static let donations = Color.purple
        static let wasteReduced = Color.yellow
        static let volunteers = Color.purple
        static let hoursContributed = Color.blue
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct Shadow {
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
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