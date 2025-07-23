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
        static let cardBackground = Color(UIColor.systemBackground)
        static let mealsServed = Color.green
        static let donations = Color.purple
        static let wasteReduced = Color.yellow
        static let hoursContributed = Color.blue
        static let volunteers = Color.orange
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct Shadow {
        static let small: CGFloat = 2
        static let medium: CGFloat = 4
        static let large: CGFloat = 8
    }
    
    static let shared = ThemeManager()
    private init() {}
} 