import SwiftUI

struct VolunteerShiftsView: View {
    @ObservedObject var viewModel: VolunteerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.registrations.isEmpty {
                    emptyStateView
                } else {
                    registrationsList
                }
            }
            .navigationTitle("My Shifts")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No shifts scheduled")
                .font(.headline)
            
            Text("When you register for volunteer opportunities, they will appear here")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var registrationsList: some View {
        List {
            ForEach(sortedRegistrations) { registration in
                VolunteerShiftRow(registration: registration)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.cancelRegistration(registration.id)
                        } label: {
                            Label("Cancel", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    private var sortedRegistrations: [VolunteerRegistration] {
        viewModel.registrations.sorted { $0.date < $1.date }
    }
}

struct VolunteerShiftRow: View {
    let registration: VolunteerRegistration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(registration.opportunityTitle)
                .font(.headline)
            
            // Date and duration
            HStack {
                // Date
                Label(registration.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.subheadline)
                
                Spacer()
                
                // Duration
                Label(registration.formattedDuration, systemImage: "clock")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            // Registration information
            Text("Registered on \(registration.registrationDate, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let viewModel = VolunteerViewModel()
    VolunteerShiftsView(viewModel: viewModel)
} 