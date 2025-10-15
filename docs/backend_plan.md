# Backend Development Plan

## Goals
- Deliver resilient APIs for the three canonical lists, nightly focus ritual, Anti-Todo ledger, and suggestion engine.
- Provide a clean contract for iOS and web clients, including type-safe schemas.
- Support offline-first sync, analytics, and future integrations.

## Milestone breakdown
1. **Core data layer**
   - Finalize schema for `list_items`, `focus_cards`, `anti_todo_entries`.
   - Implement migrations (Drizzle/Prisma) and seeding scripts.
   - Wrap persistence in repositories with interfaces for alternative databases.
2. **API endpoints**
   - CRUD for list items with diff/sync support.
   - Focus card endpoints (`GET`, `POST /generate`, `PUT`).
   - Anti-Todo logging + day summary retrieval.
3. **Sync & heuristics**
   - Device token management, conflict detection, merge policies.
   - Structured procrastination recommendation service (initial heuristics).
   - Nightly worker for focus card pre-generation.
4. **Observability & quality**
   - Add pino logger, OpenTelemetry traces, structured error responses.
   - Vitest suites (unit + contract), supertest integration tests, load testing harness.
   - CI pipelines (GitHub Actions) covering lint, test, build.
5. **Integrations**
   - Calendar ingestion (Google/Outlook) for deadlines.
   - Email digests summarizing Anti-Todo wins.
   - Webhooks for third-party automations.

## Decision log
- Framework: Fastify for speed + type safety.
- Validation: Zod via fastify type provider.
- Queue: Start with in-process scheduler; graduate to BullMQ or Temporal.
- Auth: Magic link provider (Clerk/Supabase). Use JWT for API gate.

## Open questions
- Which analytics warehouse (BigQuery vs Snowflake) best suits event volume?
- Should structured procrastination suggestions integrate with personal calendar priority?
- Evaluate CRDT vs server-authoritative merge as user base scales.
