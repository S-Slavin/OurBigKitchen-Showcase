import Foundation
import Combine

class VolunteerViewModel: ObservableObject {
    @Published var opportunities: [VolunteerOpportunity] = []
    @Published var filteredOpportunities: [VolunteerOpportunity] = []
    @Published var selectedOpportunity: VolunteerOpportunity?
    @Published var registrations: [VolunteerRegistration] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showSuccessMessage = false
    @Published var searchText = ""
    @Published var selectedCategory: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let statsManager: StatsManager
    
    // Available categories for filtering
    let categories = [
        "Kitchen", "Delivery", "Serving", "Cleaning", 
        "Administrative", "Event", "Other"
    ]
    
    init(statsManager: StatsManager = StatsManager.shared) {
        self.statsManager = statsManager
        loadOpportunities()
        loadRegistrations()
        
        // Setup search and filter
        $searchText
            .combineLatest($selectedCategory, $opportunities)
            .map { searchText, category, opportunities in
                self.filterOpportunities(opportunities, searchText: searchText, category: category)
            }
            .assign(to: &$filteredOpportunities)
    }
    
    // MARK: - Data Loading
    
    func loadOpportunities() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For now, we'll use mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.opportunities = [
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Kitchen Assistant",
                    organization: "Our Big Kitchen",
                    description: "Help prepare meals in the kitchen. Tasks include chopping vegetables, cooking, and packaging meals.",
                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    duration: 3 * 60 * 60, // 3 hours in seconds
                    location: "123 Main St",
                    category: "Kitchen",
                    spotsTotal: 5,
                    spotsTaken: 2,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Meal Delivery Driver",
                    organization: "Our Big Kitchen",
                    description: "Deliver prepared meals to elderly community members and those in need.",
                    date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                    duration: 2 * 60 * 60, // 2 hours in seconds
                    location: "123 Main St",
                    category: "Delivery",
                    spotsTotal: 3,
                    spotsTaken: 1,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Soup Kitchen Server",
                    organization: "Our Big Kitchen",
                    description: "Serve meals to those in need at our community kitchen.",
                    date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                    duration: 4 * 60 * 60, // 4 hours in seconds
                    location: "123 Main St",
                    category: "Serving",
                    spotsTotal: 4,
                    spotsTaken: 0,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Kitchen Cleanup Crew",
                    organization: "Our Big Kitchen",
                    description: "Help clean and sanitize the kitchen after meal preparation and service.",
                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    duration: 2 * 60 * 60, // 2 hours in seconds
                    location: "123 Main St",
                    category: "Cleaning",
                    spotsTotal: 3,
                    spotsTaken: 1,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Administrative Support",
                    organization: "Our Big Kitchen",
                    description: "Help with administrative tasks such as data entry, phone calls, and coordination.",
                    date: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
                    duration: 3 * 60 * 60, // 3 hours in seconds
                    location: "123 Main St",
                    category: "Administrative",
                    spotsTotal: 2,
                    spotsTaken: 0,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Community Event Helper",
                    organization: "Our Big Kitchen",
                    description: "Assist with setting up, running, and cleaning up after a community dinner event.",
                    date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                    duration: 5 * 60 * 60, // 5 hours in seconds
                    location: "456 Park Ave",
                    category: "Event",
                    spotsTotal: 6,
                    spotsTaken: 2,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Kids Giving Back",
                    organization: "Our Big Kitchen",
                    description: "A special program designed for children aged 8-16 to learn about food preparation, nutrition, and giving back to the community. Kids will work alongside experienced chefs to prepare meals for those in need while learning important kitchen skills.",
                    date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                    duration: 2.5 * 60 * 60, // 2.5 hours in seconds
                    location: "123 Main St",
                    category: "Kitchen",
                    spotsTotal: 10,
                    spotsTaken: 3,
                    imageURL: nil
                ),
                VolunteerOpportunity(
                    id: UUID(),
                    title: "Food Rescue Program",
                    organization: "Our Big Kitchen",
                    description: "Help rescue surplus food from local grocery stores, farmers markets, and restaurants. Volunteers will collect, sort, and help redistribute fresh food that would otherwise go to waste. Great opportunity for families and youth volunteers to learn about food sustainability.",
                    date: Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date(),
                    duration: 3 * 60 * 60, // 3 hours in seconds
                    location: "456 Park Ave",
                    category: "Delivery",
                    spotsTotal: 8,
                    spotsTaken: 2,
                    imageURL: nil
                )
            ]
            
            self.filteredOpportunities = self.opportunities
            self.isLoading = false
        }
    }
    
    func loadRegistrations() {
        // In a real app, this would fetch from persistent storage or an API
        guard let data = UserDefaults.standard.data(forKey: "volunteerRegistrations") else {
            // No saved registrations
            return
        }
        
        do {
            registrations = try JSONDecoder().decode([VolunteerRegistration].self, from: data)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Actions
    
    func registerForOpportunity(_ opportunity: VolunteerOpportunity, name: String, email: String, phone: String, notes: String) {
        guard !name.isEmpty, !email.isEmpty else {
            self.error = NSError(
                domain: "VolunteerError",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Name and email are required"]
            )
            return
        }
        
        isLoading = true
        
        // Create a registration
        let registration = VolunteerRegistration(
            id: UUID(),
            opportunityId: opportunity.id,
            opportunityTitle: opportunity.title,
            date: opportunity.date,
            duration: opportunity.duration,
            name: name,
            email: email,
            phone: phone,
            notes: notes,
            registrationDate: Date()
        )
        
        // Update stats via StatsManager
        statsManager.addVolunteerRegistration(registration)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                // Add to registrations
                self.registrations.append(registration)
                
                // Save to persistent storage
                self.saveRegistrations()
                
                // Show success message
                self.showSuccessMessage = true
                self.isLoading = false
                
                // Hide success message after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showSuccessMessage = false
                }
            }
            .store(in: &cancellables)
    }
    
    func cancelRegistration(_ registrationId: UUID) {
        registrations.removeAll { $0.id == registrationId }
        saveRegistrations()
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
    }
    
    // MARK: - Helpers
    
    private func filterOpportunities(_ opportunities: [VolunteerOpportunity], searchText: String, category: String?) -> [VolunteerOpportunity] {
        var filtered = opportunities
        
        // Filter by category if selected
        if let category = category, !category.isEmpty {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text if provided
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.organization.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    // MARK: - Persistence
    
    private func saveRegistrations() {
        do {
            let data = try JSONEncoder().encode(registrations)
            UserDefaults.standard.set(data, forKey: "volunteerRegistrations")
        } catch {
            self.error = error
        }
    }
}

// MARK: - Models

struct VolunteerRegistration: Identifiable, Codable {
    let id: UUID
    let opportunityId: UUID
    let opportunityTitle: String
    let date: Date
    let duration: TimeInterval
    let name: String
    let email: String
    let phone: String
    let notes: String
    let registrationDate: Date
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        return "\(hours) \(hours == 1 ? "hour" : "hours")"
    }
} 