# iOS Development Plan

## Architecture
- **App**: SwiftUI app with modular feature packages (Focus, Lists, Anti-Todo, Settings).
- **Data**: SwiftData (fallback to CoreData) as local cache, bridging to shared `ListItem` structs.
- **Networking**: `SyncService` built on async/await, background fetch tasks, retry policies.
- **State**: Observable objects per feature with `@MainActor` annotated view models.
- **Widgets/Intents**: Home Screen widget for today's focus card, App Intents for quick capture and Anti-Todo logging.

## Milestones
1. **Scaffold** — Wire feature shells, load placeholder data, integrate design tokens once delivered.
2. **Local persistence** — Map domain models to SwiftData entities, implement quick capture and offline-first flow.
3. **Sync** — Connect to Fastify API, manage sync tokens, handle conflict resolution.
4. **Ritual flows** — Nightly planning wizard (Step-by-step), Anti-Todo entry, reflection summary view.
5. **Notifications** — Local notifications for nightly planning reminder, midday check-in, end-of-day reflection.
6. **Polish** — Accessibility, haptics, animations aligned with FE/UI agent guidance.

## Tooling
- `xcodegen` to codify project structure once designs land.
- Snapshot tests for key screens using `ViewImageConfig`.
- Fastlane for TestFlight distribution and screenshot automation.

## Risks & mitigations
- **SwiftData maturity**: Keep CoreData adapter ready if stability issues arise.
- **Background refresh**: Validate tasks against iOS energy budgets, fallback to silent push.
- **Sync conflicts**: Mirror backend merge rules in `SyncService`.
