# Delivery Plan

## Phase 0 — Foundations (Week 0-1)
- Finalize domain models and API contracts.
- Implement SQLite persistence layer with migration scaffolding.
- Establish automated formatting, linting, and testing pipelines.
- Create skeleton Swift modules and integrate with shared domain schemas.

## Phase 1 — Core Lists (Week 2-4)
- CRUD endpoints for Todo, Watch, Later lists.
- Sync tokens + diff endpoints for clients.
- iOS local store + list management views (UI agent to style).
- Seed structured procrastination heuristics (e.g., task duration, energy tags).

## Phase 2 — Rituals (Week 5-7)
- Nightly focus card generator + manual overrides.
- Anti-Todo logging endpoints and timeline view wiring.
- Notification scheduling (local iOS notifications, email via worker).
- Analytics snapshots (completed vs planned delta, streaks).

## Phase 3 — Intelligence (Week 8-10)
- Enrich suggestion engine with calendar integration (read-only).
- Adaptive heuristics for re-ordering watch list follow-ups.
- Machine-learned prioritization backlog (data capture only).
- User settings for focus windows, energy states, and reminders.

## Phase 4 — Polish & Launch (Week 11-12)
- QA, load testing, and accessibility pass.
- Beta onboarding flows, guided tutorials.
- Production infrastructure (managed Postgres, Vercel/Render deployment).
- App Store/TestFlight readiness; PWA packaging for web.

## Workstreams & ownership
- **Product & Design**: Ritual blueprint, user research (collab with FE/UI agent).
- **iOS**: SwiftUI client, offline cache, background tasks, app intents.
- **Web**: Frontend implementation (deferred to FE/UI agent).
- **API/Backend**: services/api, background workers, persistence.
- **Infra/DevEx**: CI/CD, observability, release automation.

## Cadence
- Weekly planning review anchored to the 3-list philosophy.
- Bi-weekly demos featuring focus card flow, Anti-Todo celebrations.
- Monthly retro across iOS + web + backend squads.
