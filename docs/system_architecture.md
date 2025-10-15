# System Architecture Overview

## High-level topology
```
iOS AndreApp      Web Frontend
     \                 /
      \               /
       --> Andre API ----> SQLite (local dev) / Postgres (prod)
                 |
                 +--> Background workers (notifications, suggestions)
                 |
                 +--> Analytics sink (Snowflake/BigQuery TBD)
```

## Domain model
- **ListItem**
  - `id`, `title`, `listType` (`Todo`, `Watch`, `Later`, `AntiTodo`)
  - `status` (`planned`, `in_progress`, `completed`, `archived`)
  - `source` (`user`, `suggestion`, `import`)
  - `dueAt`, `followUpAt`, `createdAt`, `completedAt`
  - `notes`, `tags`, `confidenceScore`
- **DailyFocusCard**
  - `id`, `date`, `items` (references to ListItems), `reflection`
  - `meta`: energy budget, focus theme, success criteria.
- **Suggestion**
  - `id`, `title`, `description`, `listType`, `score`
  - `source`: `later`, `watch`, or `momentum` (recent Anti-Todo wins)

## Data flow
1. **Capture** — iOS and web clients push ListItems to the API. Mutations emit domain events (`ListItemCreated`, `ListItemUpdated`).
2. **Sync** — Clients request diff feeds using `updatedSince`. The API tracks device checkpoints via sync tokens; conflict resolution is last-write-wins with merge patches and server-side validation for list assignment rules.
3. **Nightly ritual** — At 21:00 local time a worker generates candidate focus cards using heuristics (recent commitments, upcoming deadlines, energy tags). Clients can accept/edit the card and persist it via the API.
4. **Anti-Todo** — Completing tasks or logging ad-hoc wins creates AntiTodo list entries. End-of-day reflection consolidates stats for analytics.
5. **Structured procrastination** — API route `GET /v1/suggestions/structured-procrastination` ranks lightweight wins (Later quick hits, Watch follow-ups, recent Anti-Todo victories) to surface when the user indicates low focus or long idle periods.

## Services/API layering
- `routes/` — HTTP adapters (Fastify) for lists, focus cards, analytics, health.
- `services/` — Orchestrate use cases (e.g., `PlanService.createFocusCard`).
- `domain/` — Pure domain logic, validation, heuristics.
- `infra/` — Persistence adapters (SQLite via better-sqlite3 for dev, pg for prod), event bus stubs, external integrations.

## Background jobs
- `generateFocusCard(date, userId)`
- `suggestStructuredProcrastination(userId)`
- `reconcileSyncConflicts(userId, deviceId)`
- `sendReminder(type, userId)`

We will start with node-cron jobs running within the API process; move to a dedicated worker (BullMQ / Temporal) in v2.

## Security & auth
- Passwordless magic links powered by Clerk or Supabase auth.
- All API endpoints require user-level auth tokens; device tokens enforce per-device sync windows.
- PII is limited; encrypted at rest in production Postgres, with audit logs.

## Observability
- Structured logging with pino -> OpenTelemetry collector.
- Metrics: request latency, queue depth, suggestion pick-up rate.
- Error monitoring via Sentry (target).

## Mobile-specific considerations
- SwiftData (or CoreData) for offline caching with periodic background refresh tasks.
- Combine / async streams for UI updates.
- App Intents for quick capture (Siri Shortcuts).

## Web-specific considerations
- React + Remix (recommended) for multi-device access; offline capability via IndexedDB.
- Shared TypeScript types generated from OpenAPI spec, enabling UI type-safety.
