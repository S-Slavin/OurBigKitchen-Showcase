OurBigKitchen – Volunteer Help Wanted

Goal: Accelerate feature completion and stabilize key flows. Below are focused volunteer roles with clear scopes.

1) iOS SwiftUI Engineer – Registration Submit & Validation
- Scope: Implement final submission in `OurBigKitchen_Restored/OurBigKitchen/Views/RegistrationFlowView.swift` and wire to backend.
- Tasks:
  - Replace TODO "Handle final submission" with API call via `RegistrationService`.
  - Validate WWCC (format + expiry) and show inline errors.
  - On success: set `appState.isAuthenticated = true`, schedule WWCC reminders.
- Skills: Swift/SwiftUI, Combine/async, form validation.

2) iOS Engineer – Password Reset Integration
- Scope: Complete `Services/PasswordResetService.swift` by calling backend endpoints.
- Tasks:
  - Implement email request and reset confirmation flows.
  - Add user feedback states and error handling.
- Skills: Swift networking, error propagation, UX polish.

3) iOS Engineer – Social Sharing
- Scope: Implement share actions in `Views/ViewModels/ImpactViewModel.swift`.
- Tasks:
  - Facebook/Twitter/Instagram intents, test share sheet flows.
  - Ensure `ImageRenderingService` renders share cards correctly.
- Skills: Social frameworks, UIKit bridging, SwiftUI.

4) iOS Engineer – Events & Volunteering APIs
- Scope: Replace placeholders with real APIs across Events/Volunteer screens.
- Files:
  - `Views/Events/EventsView.swift` – events feed API
  - `Views/Events/CorporateEventsView.swift` – submission API
  - `Views/VolunteerView.swift` – volunteer list + sign-up
  - `Views/EventRebookingView.swift` – rebooking actions
- Skills: REST/GraphQL, paginated lists, form submissions.

5) QA Engineer – Automated Tests
- Scope: Add unit and UI tests for critical paths.
- Tasks:
  - Unit: `AuthService`, `AuthManager`, `RegistrationFlowViewModel`.
  - UI: onboarding → auth type → login → registration (happy path + errors).
- Skills: XCTest, XCUITest, test data management.

6) DevOps – CI Setup
- Scope: Configure CI to build and run tests on PRs.
- Tasks:
  - Xcode build matrix for latest iOS, cache dependencies.
  - Ensure artifacts and logs are attached to builds.
- Skills: GitHub Actions (or preferred CI), Xcode build tooling.

How to Contribute
- Branch from `original-obk`.
- Keep changes scoped to the listed files/areas.
- Add/update tests where relevant.
- Use conventional commits: type(scope): message.

Contacts
- Maintainer: Open an issue or PR in `OurBigKitchen-Showcase` repository.


