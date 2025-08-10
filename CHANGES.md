Changelog

2025-08-10
- fix(auth): Remove conflicting old auth views (WWCAuthView, WWCSignInView, IndividualSignInView) to stop mixed slides
- fix(nav): Simplify RootView logic to avoid overlapping views
- fix(env): Inject ImpactService, AuthService, SessionService into app environment
- fix(registration): Use ScrollViewReader; restore "SKIP FOR DEMO"; set authentication state on completion
- chore(context): Add PROJECT_CONTEXT.md with current status and milestones

2025-08-06 – 2025-08-09
- restore(core): Restore major components from reference backup, resolve duplicates and model conflicts
- fix(models): Deduplicate UserRanking/Category, add Equatable, adjust initializers
- fix(auth-vm): Replace @Observable with ObservableObject; correct Combine integration; add loginWithApple stub
- chore(clean): Remove unused/old architecture files (TCA remnants, MainFeature/MainView, duplicate services)


