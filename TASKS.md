Tasks and Open Items

Status legend: [ ] todo, [~] in progress, [x] done

Authentication & Onboarding
- [x] Clean old vs new slides conflict in auth flow
- [x] Ensure custom 4-page welcome slides are present
- [ ] Add unit tests for RootView navigation gating

Registration
- [~] Implement final submission in `Views/RegistrationFlowView.swift` (line ~437 TODO)
- [ ] Validate WWCC format per NSW spec and surface errors inline
- [ ] Hook registration submit to backend + schedule WWCC reminders via backend if applicable

Password Reset
- [ ] Implement backend calls in `Services/PasswordResetService.swift`

Impact / Sharing
- [ ] Implement Facebook/Twitter/Instagram share actions in `Views/ViewModels/ImpactViewModel.swift`
- [ ] Verify `ImageRenderingService` share card render path on device

Events & Volunteering
- [ ] Implement Events list API in `Views/Events/EventsView.swift`
- [ ] Implement Corporate event form submission in `Views/Events/CorporateEventsView.swift`
- [ ] Implement Volunteer list and sign-up actions in `Views/VolunteerView.swift`
- [ ] Implement Event rebooking flows in `Views/EventRebookingView.swift`

Testing & CI
- [ ] Add unit tests for `AuthService`, `AuthManager`, `RegistrationFlowViewModel`
- [ ] Add UI tests for onboarding → login → registration happy path
- [ ] Configure CI to run tests on PRs

Documentation
- [x] Add `PROJECT_CONTEXT.md` snapshot
- [x] Add `CHANGES.md` entries
- [ ] Keep TASKS.md updated as work progresses


