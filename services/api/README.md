## Andre API Service

Fastify-based backend that powers the Andre productivity ecosystem. It exposes list management, nightly planning, Anti-Todo logging, and suggestion endpoints to both iOS and web clients.

### Stack
- Fastify + Zod for runtime validation.
- SQLite (better-sqlite3) locally, PostgreSQL in production.
- Vitest for unit and contract testing.

### Commands
```bash
pnpm install
pnpm dev     # start API with hot reload
pnpm test    # run test suite (vitest)
pnpm build   # compile TypeScript
```

### Folder layout
- `src/domain` — Pure domain types and business rules.
- `src/services` — Use-case orchestration.
- `src/routes` — HTTP handlers mapping to service calls.
- `src/infra` — Persistence and external adapters.
- `tests/` — Unit + contract tests.

### Key endpoints
- `GET /v1/lists/sync` — Fetch the three-list board snapshot (Todo/Watch/Later/Anti-Todo).
- `POST /v1/lists` — Create a list entry; `PUT /v1/lists/:id` updates; `DELETE /v1/lists/:id` removes.
- `POST /v1/focus-card/generate` — Draft the nightly focus card; `GET /v1/focus-card` retrieves committed cards.
- `POST /v1/anti-todo` — Log a completed win; `GET /v1/anti-todo?date=YYYY-MM-DD` returns the day’s Anti-Todo ledger.
- `GET /v1/suggestions/structured-procrastination` — Suggest quick wins when procrastination hits (optional `limit=1..10`).

### Next steps
- Flesh out migrations + Postgres adapter.
- Implement background job runner for nightly focus cards.
- Generate OpenAPI schema for UI agent consumption.
