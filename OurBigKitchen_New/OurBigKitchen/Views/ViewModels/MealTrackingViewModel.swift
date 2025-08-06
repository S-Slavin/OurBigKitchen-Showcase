import Foundation
import Combine

@MainActor
class MealTrackingViewModel: ObservableObject, @unchecked Sendable {
    @Published var mealEntry: MealEntry = .empty
    @Published var recentEntries: [MealEntry] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showSuccessMessage = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Common dish names for quick selection
    let commonDishes = [
        "Beef Stew", "Chicken Soup", "Vegetable Curry", 
        "Pasta Bolognese", "Sandwich Platter", "Rice & Beans",
        "Salad", "Pizza", "Fruit Platter"
    ]
    
    // Group codes for selection
    let groupCodes = [
        "COMM001", "SCHOOL002", "SHELTER003", "CHARITY004", 
        "EVENT005", "OUTREACH006", "OTHER999"
    ]
    
    init() {
        loadRecentEntries()
    }
    
    func submitMealEntry() {
        guard mealEntry.isValid else {
            self.error = NSError(
                domain: "MealTrackingError",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Please complete all required fields"]
            )
            return
        }
        
        isLoading = true
        
        // Create a copy of the meal entry with a new ID
        let entryToSubmit = MealEntry(
            id: UUID(),
            groupCode: mealEntry.groupCode,
            dishName: mealEntry.dishName,
            mealCount: mealEntry.mealCount,
            date: mealEntry.date
        )
        
        // Update stats via StatsManager asynchronously
        Task {
            do {
                let _ = try await StatsManager.shared.addMealEntryAsync(entryToSubmit)
                
                await MainActor.run {
                    // Add entry to recent entries
                    self.recentEntries.insert(entryToSubmit, at: 0)
                    
                    // Save to persistent storage
                    self.saveRecentEntries()
                    
                    // Reset form and show success
                    self.mealEntry = .empty
                    self.showSuccessMessage = true
                    self.isLoading = false
                    
                    // Hide success message after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.showSuccessMessage = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func selectDish(_ dish: String) {
        mealEntry.dishName = dish
    }
    
    func selectGroupCode(_ code: String) {
        mealEntry.groupCode = code
    }
    
    // MARK: - Persistence
    
    private func saveRecentEntries() {
        // Limit to last 10 entries
        let entriesToSave = Array(recentEntries.prefix(10))
        
        do {
            let data = try JSONEncoder().encode(entriesToSave)
            UserDefaults.standard.set(data, forKey: "recentMealEntries")
        } catch {
            self.error = error
        }
    }
    
    private func loadRecentEntries() {
        guard let data = UserDefaults.standard.data(forKey: "recentMealEntries") else {
            // No saved entries
            return
        }
        
        do {
            recentEntries = try JSONDecoder().decode([MealEntry].self, from: data)
        } catch {
            self.error = error
        }
    }
} 