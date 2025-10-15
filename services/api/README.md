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

### Next steps
- Flesh out migrations + Postgres adapter.
- Implement background job runner for nightly focus cards.
- Generate OpenAPI schema for UI agent consumption.
