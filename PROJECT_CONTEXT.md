OurBigKitchen – Project Context (Current Status)

Last updated: 2025-08-10

Overview
- The OurBigKitchen app in `OurBigKitchen_Restored/` is the working target.
- App builds and runs on iOS Simulator. Authentication flow cleaned and stable.
- Custom 4-page onboarding slides are present and correct (enhanced logo + 3 feature slides).
- WWCC is integrated into the main registration flow (18+ requires number and expiry; reminders scheduled).

Current App Flow
- First launch: `UserWelcomeView` → `AuthTypeSelectionView` → `SimpleSignInView`.
- Login: In `SimpleSignInView`.
- Sign Up: `SimpleSignInView` → `RegistrationSignupSlidesView` (multi-step with WWCC when 18+).
- Terms and Health: `SimpleTermsView` and `HealthProtocolView` after authentication.
- Main App: `ContentView` once prerequisites complete.

Key Stability Fixes Landed
- Simplified root navigation to avoid overlapping views (“mish-mash”).
- Injected missing environment objects: `ImpactService`, `AuthService`, `SessionService`.
- Replaced invalid scroll detection with `ScrollViewReader` in registration.
- Removed old/conflicting auth views to stop mixed old/new slides.
- Verified `UserWelcomeView` matches custom design and animations.

Known Gaps / Work Needed (high-level)
- Networking/API: Several screens use placeholder data and marked TODOs for API calls.
- Registration finalization: one TODO remains for final submission in `RegistrationFlowView`.
- Social sharing: Facebook/Twitter/Instagram share actions are stubs in `ImpactViewModel`.
- Events & volunteer flows: Corporate events submission, volunteer sign-up, events list and rebooking flows have TODOs.
- Password reset: Service is stubbed; needs backend hookup.
- Testing & CI: Minimal automated tests for the restored target; CI not configured.

Primary Code Locations
- Entry: `OurBigKitchen_Restored/OurBigKitchen/Roots/OurBigKitchenApp.swift`
- Onboarding: `OurBigKitchen_Restored/OurBigKitchen/Services/UserWelcomeView.swift`
- Auth: `OurBigKitchen_Restored/OurBigKitchen/Views/SimpleSignInView.swift`, `Views/Authentication/AuthTypeSelectionView.swift`, `Services/AuthService.swift`, `Managers/AuthManager.swift`
- Registration: `Views/RegistrationSignupSlidesView.swift`, `Views/RegistrationFlowView.swift`, `Views/ViewModels/RegistrationFlowViewModel.swift`
- Impact & Sharing: `Services/ImageRenderingService.swift`, `Views/ViewModels/ImpactViewModel.swift`
- Events & Volunteering: `Views/Events/`, `Views/VolunteerView.swift`, `Views/EventRebookingView.swift`, `Views/Events/CorporateEventsView.swift`

Environment/State
- Global state via `AppState` and environment objects; `objectWillChange.send()` used to refresh after onboarding.
- `UserDefaults.hasSeenOnboarding` respected only by onboarding.

Next Suggested Milestones
1) Replace placeholder APIs with real endpoints (events, volunteering, registration submit, password reset).
2) Implement social share integrations and test share card rendering paths.
3) Add unit/UI tests for auth/registration and core flows; set up CI.
4) Polish UX details and error states across registration and events.


