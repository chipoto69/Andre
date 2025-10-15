# Andre

Andre is a cross-platform productivity companion inspired by Marc Andreessen's three-list philosophy. It helps users capture and act on their Todo, Watch, and Later commitments; orchestrate nightly focus cards; celebrate daily accomplishments via the Anti-Todo ledger; and leverage structured procrastination to keep momentum high.

## Project layout
- `docs/` — product vision, system design notes, delivery roadmap, and agent briefs.
- `apps/ios/` — SwiftUI application scaffold with modular feature folders.
- `apps/web/frontend/` — reserved for a dedicated UI agent to deliver the multi-device web experience.
- `services/api/` — TypeScript Fastify service that powers list management, daily planning, analytics, and sync.
- `infrastructure/` — deployment, observability, and data-migration plans.
- `scripts/` — automation entry points for local dev and continuous delivery.

## Development quickstart
1. Install toolchains
   - iOS: Xcode 15.2+ with Swift 5.9 toolchain.
   - API: Node.js 20 LTS, pnpm (preferred) or npm.
   - Database: SQLite for local development (cloud Postgres in production).
2. Bootstrap dependencies
   ```bash
   cd services/api
   pnpm install
   ```
3. Run the API locally
   ```bash
   pnpm dev
   ```
4. (Future) Run iOS previews through Xcode's preview canvas or `xcodebuild` once the project file is generated.

## High-level capabilities
- **Core lists**: Todo, Watch, Later with rich metadata, quick triage, and smart filters.
- **Nightly focus ritual**: Auto-suggest the next day's 3–5 focus items using list heuristics, calendar context, and streak data.
- **Anti-Todo ledger**: Capture completed tasks for daily reflection and analytics.
- **Structured procrastination**: Suggest opportunistic wins when focus is low, re-routing energy into meaningful progress.
- **Sync + notifications**: Keep the iOS and web experiences aligned with background refresh and timely reminders.

See `docs/product_brief.md` for a deeper overview and roadmap details.
