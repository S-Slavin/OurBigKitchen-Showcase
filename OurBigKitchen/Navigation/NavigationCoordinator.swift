class NavigationCoordinator: ObservableObject {
    @Published var path: [NavigationDestination] = []
    
    enum NavigationDestination: Hashable {
        case profile
        case photoDetail(Photo)
        case eventDetail(Event)
        case settings
        case impact
        case community
    }
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeAll()
    }
} 