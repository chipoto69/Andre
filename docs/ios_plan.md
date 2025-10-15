# iOS Roadmap (Q1 2026)

## Vision
Deliver a SwiftUI experience that works offline-first, syncs safely with the API, and showcases rituals (focus, lists, wins, suggestions).

---

## 1. Persistence & Sync (Now)
- [ ] Finish SwiftData integration: ensure all `ListItem`, `FocusCard`, `AntiTodoEntry`, `SyncQueueOperation` mappers round-trip without placeholder data.
- [ ] Replace in-memory defaults with empty states; show loading/skeleton content until data arrives.
- [ ] Initialise `OfflineQueueProcessor` after onboarding and tie into `NetworkMonitor`.
- [ ] Align `APIClient`/`SyncService` base URLs with environment configuration (dev/stage/prod) and propagate auth tokens once backend is ready.
- [ ] Add unit tests for `LocalStore`, `SuggestionsViewModel`, `ListBoardViewModel`, `FocusCardViewModel` using dependency injection.

## 2. Conflict Handling & UX
- [ ] Handle optimistic-lock conflicts from the backend (surface 409 errors with retry/refresh UI).
- [ ] Provide user-friendly error toasts instead of console logs within `ListBoardViewEnhanced`, `FocusCardView`, `AntiTodoViewEnhanced`, `StructuredProcrastinationView`.
- [ ] Break `AndreApp.swift` into feature routers; inject view models via initialisers so tests and previews can supply mocks.

## 3. Ritual Experience
- [ ] Wire structured procrastination tab to live data (already scaffolded) and add interaction metrics.
- [ ] Polish planning wizard: reuse pre-selected items from lists tab, allow manual ordering, and persist selections when the wizard dismisses/reopens.
- [ ] Add quick-add wins sheet with lightweight validation and haptics.

## 4. Accessibility & Theming
- [ ] Support system light/dark mode (remove hardcoded `.preferredColorScheme(.dark)` calls, ensure design tokens handle both).
- [ ] Audit key flows for VoiceOver and Dynamic Type; add snapshot tests for large text sizes.

## 5. Release Readiness
- [ ] Create Fastlane lanes for build/test, screenshot generation, and TestFlight deployment.
- [ ] Stand up UI snapshot tests (e.g., ViewInspector/ViewImage).
- [ ] Document environment setup (Xcode version, schemes, required `.env` values) in `apps/ios/README.md`.

## Risks / Watchlist
- SwiftData updates may break migrations—keep migration tests and fallback plan (CoreData) ready.
- Network queue must handle background execution limits; monitor energy impact once live.
