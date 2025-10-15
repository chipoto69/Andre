# Agent Execution Guide

## Context
Andre operationalises Marc Andreessen’s three-list methodology (Todo, Watch, Later) with nightly focus cards, Anti-Todo reflections, and structured procrastination coaching. Every change should honour that ritual while keeping iOS, web, and backend in sync.

## Current Roadmap Priorities (Q1 2026)
Refer to the updated delivery roadmap (`docs/delivery_plan.md`) for full detail. High-priority items for all agents:
1. **Security & Auth** – introduce user-scoped authentication across the API.
2. **Schema & Migrations** – adopt migrations and add `user_id`, `version`, `updated_at` fields.
3. **Contract Alignment** – make sure backend/web/iOS speak the same endpoints (`/v1/focus-card`, `/v1/anti-todo?date=`, `/v1/lists/sync`).
4. **Offline Readiness** – finish SwiftData + offline queue on iOS and hook IndexedDB cache/sync on web.
5. **Testing & CI** – expand automated coverage and enforce it in CI before merging.

## Core Responsibilities
1. Maintain parity between iOS and web features by sharing domain models and API contracts.
2. Keep the nightly ritual sacred—ensure every change supports effortless preparation of the next day’s 3–5 focus items.
3. Reinforce momentum by tracking Anti-Todo entries and surfacing structured procrastination wins.
4. Guard user trust through robust syncing, conflict resolution, telemetry, and observability.

## Workflow Expectations
- **Roadmap alignment**: before opening an issue/PR, confirm it maps to an item in `docs/delivery_plan.md` or log why it’s net-new.
- **Backlog hygiene**: track “Must / Watch / Later” labels to mirror the three-list philosophy.
- **Branching**: trunk-based with short-lived feature branches (e.g., `feat/web-contract-alignment`). Rebase before merge.
- **Testing**: keep fast unit/integration tests for every surface. Add contract tests whenever API shapes change.
- **Docs first**: update the relevant roadmap doc (`backend_plan.md`, `ios_plan.md`, `web_development_roadmap.md`) before landing implementation.
- **Agent hand-offs**: PR descriptions must list state, blockers, follow-up tasks, and relevant roadmap items.

## Definition of Done
- Code compiles/lints; tests updated and passing locally + in CI.
- Logging/telemetry added for new behaviours.
- Documentation updated (README, docs, API specs, environment setup).
- Rollout and rollback steps captured in the PR (feature flags, migrations, data considerations).

## Coordination Notes
- **Backend ↔️ Clients**: When you adjust an endpoint, immediately patch `lib/api-client.ts` (web) and `SyncService`/DTOs (iOS). Add contract tests.
- **Offline work**: Queue processors (iOS `OfflineQueueProcessor`, web `syncQueue`) must be kept functional—update both if API semantics change.
- **Design tokens**: Keep colour/spacing/typography aligned across web/iOS; consult `components/ui` and SwiftUI design system files before deviating.

## Command Center
- Backend: `pnpm dev` (Fastify) in `services/api`; use `pnpm test` for Vitest suites.
- Web: `pnpm dev` in `apps/web/frontend`; ensure `NEXT_PUBLIC_API_URL` points to the running backend.
- iOS: open `apps/ios/AndreApp/Package.swift` in Xcode; previews rely on accurate env config.
- Suggestions endpoint: `GET /v1/suggestions/structured-procrastination?limit=5` for quick verification.

Stay disciplined: update roadmap checkboxes as items land, and flag blockers early so other agents can swarm.
