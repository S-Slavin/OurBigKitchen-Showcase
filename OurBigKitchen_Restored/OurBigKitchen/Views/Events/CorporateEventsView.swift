import SwiftUI

struct CorporateEventsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedEventType: CorporateEventType? = nil
    @State private var ageGroup: AgeGroup = .adults
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var mobile = ""
    @State private var company = ""
    @State private var eventDate = Date()
    @State private var preferredTime: PreferredTime? = nil
    @State private var pax = ""
    @State private var description = ""
    @State private var showValidation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Event Highlights
                VStack(alignment: .leading, spacing: 16) {
                    Text("Explore More Group Events at OBK")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeManager.Colors.primaryText)
                        .padding(.bottom, 4)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(CorporateEventType.allCases, id: \.self) { eventType in
                            EventTypeCard(
                                eventType: eventType,
                                isSelected: selectedEventType == eventType
                            ) {
                                withAnimation {
                                    selectedEventType = eventType
                                    if eventType != .birthdayParty { ageGroup = .adults }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Booking Form
                VStack(alignment: .leading, spacing: 20) {
                    Text("Register Your Team")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeManager.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)

                    // Form fields
                    Group {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("First Name")
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                                    .overlay(validationOverlay(firstName))
                            }
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("Last Name")
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                                    .overlay(validationOverlay(lastName))
                            }
                        }
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("Email")
                                TextField("Email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .overlay(validationOverlay(email))
                            }
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("Mobile")
                                TextField("Mobile", text: $mobile)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                                    .overlay(validationOverlay(mobile))
                            }
                        }
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("Company")
                                TextField("Company", text: $company)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                                    .overlay(validationOverlay(company))
                            }
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("Event Type")
                                Picker("Event Type", selection: $selectedEventType) {
                                    Text("Please select").tag(CorporateEventType?.none)
                                    ForEach(CorporateEventType.allCases, id: \.self) { type in
                                        Text(type.title).tag(CorporateEventType?.some(type))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .overlay(validationOverlay(selectedEventType == nil ? "" : "ok"))
                            }
                        }
                        if selectedEventType == .birthdayParty {
                            VStack(alignment: .leading) {
                                RequiredFieldLabel("Age Group")
                                Picker("Age Group", selection: $ageGroup) {
                                    ForEach(AgeGroup.allCases, id: \.self) { group in
                                        Text(group.rawValue).tag(group)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Event Date")
                                DatePicker("Event Date", selection: $eventDate, displayedComponents: [.date])
                                    .labelsHidden()
                            }
                            VStack(alignment: .leading) {
                                Text("Preferred Time")
                                Picker("Preferred Time", selection: $preferredTime) {
                                    Text("Please select").tag(PreferredTime?.none)
                                    ForEach(PreferredTime.allCases, id: \.self) { time in
                                        Text(time.rawValue).tag(PreferredTime?.some(time))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("# of Pax")
                                TextField("# of Pax", text: $pax)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            VStack(alignment: .leading) {
                                Text("Description")
                                TextField("Please type your message here...", text: $description)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }

                    Button(action: submitForm) {
                        Text("Submit Request")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ThemeManager.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(ThemeManager.Colors.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(ThemeManager.Colors.background)
        .navigationTitle("Corporate Events")
        .navigationBarTitleDisplayMode(.large)
    }

    private func submitForm() {
        showValidation = true
        // TODO: Implement form submission logic
    }

    private func validationOverlay(_ value: String) -> some View {
        Group {
            if showValidation && value.isEmpty {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.red, lineWidth: 1)
            }
        }
    }
}

fileprivate struct RequiredFieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(spacing: 2) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(ThemeManager.Colors.primaryText)
            Text("*")
                .foregroundColor(.red)
        }
    }
}

fileprivate struct EventTypeCard: View {
    let eventType: CorporateEventType
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: eventType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(ThemeManager.Colors.primary)
                    .clipShape(Circle())
                Text(eventType.title)
                    .font(.headline)
                    .foregroundColor(ThemeManager.Colors.primaryText)
                Text(eventType.description)
                    .font(.caption)
                    .foregroundColor(ThemeManager.Colors.secondaryText)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ThemeManager.Colors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeManager.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

enum AgeGroup: String, CaseIterable {
    case youngChildren = "3-8 years"
    case olderChildren = "9-12 years"
    case adults = "Adults"
}

enum PreferredTime: String, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
}

fileprivate enum CorporateEventType: String, CaseIterable, Hashable {
    case schoolProgram
    case birthdayParty
    case familyCooking
    case challahBake

    var title: String {
        switch self {
        case .schoolProgram: return "School Programs"
        case .birthdayParty: return "Birthday Parties"
        case .familyCooking: return "Cooking with Family"
        case .challahBake: return "Challah Bakes"
        }
    }
    var description: String {
        switch self {
        case .schoolProgram: return "Educational cooking programs for schools and educational institutions"
        case .birthdayParty: return "Celebrate birthdays with cooking activities for all ages"
        case .familyCooking: return "Family bonding through cooking activities"
        case .challahBake: return "Traditional challah baking workshops"
        }
    }
    var icon: String {
        switch self {
        case .schoolProgram: return "book.fill"
        case .birthdayParty: return "gift.fill"
        case .familyCooking: return "person.3.fill"
        case .challahBake: return "circle.grid.cross.fill"
        }
    }
} 