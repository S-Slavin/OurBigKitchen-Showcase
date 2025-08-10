import Foundation

extension Notification.Name {
    static let didUpdateAuth = Notification.Name("didUpdateAuth")
    static let didLogout = Notification.Name("didLogout")
    static let didLogin = Notification.Name("didLogin")
    static let didUpdateUser = Notification.Name("didUpdateUser")
    static let didDeleteUser = Notification.Name("didDeleteUser")
    static let didUpdateTerms = Notification.Name("didUpdateTerms")
    static let didUpdateHealthProtocols = Notification.Name("didUpdateHealthProtocols")
    static let didUpdateContribution = Notification.Name("didUpdateContribution")
    static let didUpdatePreferences = Notification.Name("didUpdatePreferences")
    static let didClearUserData = Notification.Name("didClearUserData")
} 