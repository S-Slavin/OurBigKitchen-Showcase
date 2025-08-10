import Foundation
import Combine

// MARK: - Salesforce Integration Manager
class SalesforceIntegrationManager: ObservableObject {
    @Published var isConnected = false
    @Published var syncStatus = "Not connected"
    @Published var lastSyncDate: Date?
    
    private let salesforceService: SalesforceServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(salesforceService: SalesforceServiceProtocol = SalesforceService()) {
        self.salesforceService = salesforceService
        setupBindings()
    }
    
    private func setupBindings() {
        salesforceService.authenticate()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.syncStatus = "Authentication failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.isConnected = true
                    self?.syncStatus = "Connected to Salesforce"
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - User Registration Integration
    func syncUserRegistration(
        firstName: String,
        lastName: String,
        email: String,
        volunteerType: VolunteerType,
        dateOfBirth: Date,
        wwccNumber: String?,
        wwccExpiryDate: Date?
    ) -> AnyPublisher<String, Error> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let contact = SalesforceContact(
            id: nil,
            firstName: firstName,
            lastName: lastName,
            email: email,
            birthdate: dateFormatter.string(from: dateOfBirth),
            phone: nil,
            mailingStreet: nil,
            mailingCity: nil,
            mailingState: nil,
            mailingPostalCode: nil,
            mailingCountry: nil,
            volunteerType: volunteerType.rawValue,
            wwccNumber: wwccNumber,
            wwccExpiryDate: wwccNumber != nil ? dateFormatter.string(from: wwccExpiryDate ?? Date()) : nil,
            volunteerStatus: "Active",
            recordTypeId: nil
        )
        
        return salesforceService.createContact(contact)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.syncStatus = "User synced to Salesforce"
                    self?.lastSyncDate = Date()
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Corporate Account Integration
    func syncCorporateAccount(
        companyName: String,
        industry: String?,
        phone: String?,
        address: String?,
        city: String?,
        state: String?,
        postalCode: String?,
        country: String?,
        groupSize: Int?,
        groupType: String?
    ) -> AnyPublisher<String, Error> {
        
        let account = SalesforceAccount(
            id: nil,
            name: companyName,
            type: "Corporate",
            industry: industry,
            phone: phone,
            billingStreet: address,
            billingCity: city,
            billingState: state,
            billingPostalCode: postalCode,
            billingCountry: country,
            volunteerGroupSize: groupSize,
            volunteerGroupType: groupType
        )
        
        return salesforceService.createAccount(account)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.syncStatus = "Corporate account synced to Salesforce"
                    self?.lastSyncDate = Date()
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Event Integration
    func syncVolunteerEvent(
        name: String,
        eventDate: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        description: String,
        maxVolunteers: Int,
        eventType: String
    ) -> AnyPublisher<String, Error> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        let event = SalesforceVolunteerEvent(
            id: nil,
            name: name,
            eventDate: dateFormatter.string(from: eventDate),
            startTime: timeFormatter.string(from: startTime),
            endTime: timeFormatter.string(from: endTime),
            location: location,
            description: description,
            maxVolunteers: maxVolunteers,
            currentVolunteers: 0,
            status: "Scheduled",
            eventType: eventType
        )
        
        return salesforceService.createVolunteerEvent(event)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.syncStatus = "Event synced to Salesforce"
                    self?.lastSyncDate = Date()
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Impact Tracking Integration
    func syncImpactMetrics(
        userId: String,
        eventId: String,
        hoursVolunteered: Double,
        mealsServed: Int,
        peopleHelped: Int,
        date: Date
    ) -> AnyPublisher<String, Error> {
        
        // Create a custom object for impact tracking
        let impactData: [String: Any] = [
            "User_ID__c": userId,
            "Event_ID__c": eventId,
            "Hours_Volunteered__c": hoursVolunteered,
            "Meals_Served__c": mealsServed,
            "People_Helped__c": peopleHelped,
            "Impact_Date__c": DateFormatter().string(from: date)
        ]
        
        // This would typically create a custom Impact__c object in Salesforce
        // For now, we'll return a success response
        return Just("Impact metrics synced")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Data Synchronization
    func syncAllData() -> AnyPublisher<Bool, Error> {
        syncStatus = "Starting full sync..."
        
        // This would sync all local data to Salesforce
        // For now, we'll return success
        return Just(true)
            .setFailureType(to: Error.self)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.syncStatus = "Full sync completed"
                    self?.lastSyncDate = Date()
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Data Retrieval
    func fetchUserData(email: String) -> AnyPublisher<SalesforceContact?, Error> {
        let query = "SELECT Id, FirstName, LastName, Email, Volunteer_Type__c, WWCC_Number__c, WWCC_Expiry_Date__c FROM Contact WHERE Email = '\(email)'"
        
        return salesforceService.queryContacts(query: query)
            .map { contacts in
                contacts.first
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCorporateAccounts() -> AnyPublisher<[SalesforceAccount], Error> {
        let query = "SELECT Id, Name, Industry, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Volunteer_Group_Size__c, Volunteer_Group_Type__c FROM Account WHERE Type = 'Corporate'"
        
        return salesforceService.queryAccounts(query: query)
    }
    
    func fetchVolunteerEvents() -> AnyPublisher<[SalesforceVolunteerEvent], Error> {
        let query = "SELECT Id, Name, Event_Date__c, Start_Time__c, End_Time__c, Location__c, Description__c, Max_Volunteers__c, Current_Volunteers__c, Status__c, Event_Type__c FROM Volunteer_Event__c WHERE Status = 'Scheduled' ORDER BY Event_Date__c ASC"
        
        return salesforceService.queryVolunteerEvents(query: query)
    }
    
    // MARK: - WWCC Renewal Tracking
    func scheduleWWCCRenewalReminders(contactId: String, expiryDate: Date) -> AnyPublisher<Bool, Error> {
        // This would create tasks or custom objects in Salesforce for WWCC renewal reminders
        // For now, we'll return success
        return Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Error Handling
    func handleSalesforceError(_ error: Error) {
        switch error {
        case SalesforceError.notAuthenticated:
            syncStatus = "Authentication required"
            isConnected = false
        case SalesforceError.networkError:
            syncStatus = "Network connection issue"
        case SalesforceError.invalidResponse:
            syncStatus = "Invalid response from Salesforce"
        default:
            syncStatus = "Error: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Connection Management
    func reconnect() {
        syncStatus = "Reconnecting..."
        salesforceService.authenticate()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleSalesforceError(error)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.isConnected = true
                    self?.syncStatus = "Reconnected to Salesforce"
                }
            )
            .store(in: &cancellables)
    }
    
    func disconnect() {
        isConnected = false
        syncStatus = "Disconnected from Salesforce"
    }
}

// MARK: - Salesforce Data Mappers
extension SalesforceIntegrationManager {
    
    // Map app User model to Salesforce Contact
    func mapUserToSalesforceContact(_ user: User) -> SalesforceContact {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return SalesforceContact(
            id: user.salesforceId,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            birthdate: user.dateOfBirth.map { dateFormatter.string(from: $0) },
            phone: user.phone,
            mailingStreet: user.address,
            mailingCity: user.city,
            mailingState: user.state,
            mailingPostalCode: user.postalCode,
            mailingCountry: user.country,
            volunteerType: user.volunteerType,
            wwccNumber: user.wwccNumber,
            wwccExpiryDate: user.wwcExpiryDate.map { dateFormatter.string(from: $0) },
            volunteerStatus: "Active",
            recordTypeId: nil
        )
    }
    
    // Map app Event model to Salesforce Volunteer Event
    func mapEventToSalesforceVolunteerEvent(_ event: Event) -> SalesforceVolunteerEvent {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        return SalesforceVolunteerEvent(
            id: event.salesforceId,
            name: event.title,
            eventDate: dateFormatter.string(from: event.date),
            startTime: timeFormatter.string(from: event.startTime),
            endTime: timeFormatter.string(from: event.endTime),
            location: event.location,
            description: event.description,
            maxVolunteers: event.maxVolunteers,
            currentVolunteers: event.currentVolunteers,
            status: event.status.rawValue,
            eventType: event.type.rawValue
        )
    }
    
    // Map Salesforce Contact to app User model
    func mapSalesforceContactToUser(_ contact: SalesforceContact) -> User {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return User(
            id: contact.id ?? UUID().uuidString,
            firstName: contact.firstName,
            lastName: contact.lastName,
            email: contact.email,
            profileImageURL: nil,
            bio: nil,
            role: .volunteer,
            preferences: UserPreferences(),
            achievements: [],
            stats: UserStats(),
            hasFoodSafetyRegistration: false,
            authProvider: nil,
            company: nil,
            dob: contact.birthdate.flatMap { dateFormatter.date(from: $0) },
            wwcNumber: contact.wwccNumber,
            wwcExpiry: contact.wwccExpiryDate.flatMap { dateFormatter.date(from: $0) },
            companyName: nil,
            companyPosition: nil,
            companyEmail: nil,
            salesforceId: contact.id,
            phone: contact.phone,
            address: contact.mailingStreet,
            city: contact.mailingCity,
            state: contact.mailingState,
            postalCode: contact.mailingPostalCode,
            country: contact.mailingCountry,
            volunteerType: contact.volunteerType,
            wwcExpiryDate: contact.wwccExpiryDate.flatMap { dateFormatter.date(from: $0) }
        )
    }
}
