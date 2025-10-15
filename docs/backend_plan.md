# Backend Roadmap (Q1 2026)

## Mission
Deliver a secure, user-scoped API that keeps web and iOS clients in sync, supports offline merges, and is production-ready.

---

## 1. Security & Identity (Now)
- [ ] Introduce authentication middleware (JWT or session) and require it on all routes.
- [ ] Extend `list_items`, `focus_cards`, `anti_todo_entries` with `user_id` + indexes.
- [ ] Update repositories/services to filter by `user_id` and reject cross-user access.
- [ ] Provide dev tooling: seeded demo user + Postman collection + `.env` template.

## 2. Schema & Migrations
- [ ] Adopt a migration framework (Drizzle/Prisma/Knex) and store migrations in repo.
- [ ] Create baseline migration reflecting current schema + new auth columns.
- [ ] Add migration run step to CI + local bootstrap scripts.

## 3. API Contract Alignment
- [x] Harmonise focus/anti-todo endpoints to `/v1/focus-card` & `/v1/anti-todo?date=` with canonical responses. *(Phase 2 iOS payloads shipped for `/focus-card/generate` and `/user/insights`)*
- [ ] Return created/updated entities (incl. server timestamps) for all POST/PUT calls.
- [ ] Add Vitest contract tests to lock behaviour for web + iOS clients.

## 4. Concurrency & Sync Safety
- [ ] Add `version`/`updated_at` columns to mutable tables.
- [ ] Enforce optimistic locking on update/delete (409 on stale version).
- [ ] Emit sync-friendly error payloads consumed by clients for retry/rollback.

## 5. Observability & Quality
- [ ] Instrument request logging, structured errors, and basic metrics (p95, failure counts).
- [ ] Expand Vitest coverage to route-level tests (lists/focus/anti-todo/suggestions).
- [ ] Introduce Playwright smoke tests hitting the deployed API once staging is ready.

## 6. Backlog / Nice-to-have
- Calendar & email integrations.
- Background worker for pre-generating focus cards & reminders.
- Analytics warehouse evaluation.

> Progress is expected to be tracked in issues referencing the checklist above. Update this plan after each sprint review.
