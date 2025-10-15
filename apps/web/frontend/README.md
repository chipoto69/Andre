# Andre Web App

Next.js 15 client for the Andre productivity system. Uses React Query + Zustand + Tailwind and mirrors the iOS design system.

## Prerequisites
- Node.js 20+
- pnpm 9+
- Backend API running locally on `http://localhost:3333` (or set `NEXT_PUBLIC_API_URL`).

## Getting Started
```bash
pnpm install
NEXT_PUBLIC_API_URL=http://localhost:3333 pnpm dev
```

The app runs at [http://localhost:3000](http://localhost:3000).

## Environment Variables
| Name | Description | Default |
| --- | --- | --- |
| `NEXT_PUBLIC_API_URL` | Base URL for the Andre API | `http://localhost:3333` |

Create an `.env.local` file if you need to override the defaults.

## Key Scripts
| Command | Description |
| --- | --- |
| `pnpm dev` | Start Next.js dev server |
| `pnpm build` | Production build |
| `pnpm lint` | ESLint (configured via `eslint.config.mjs`) |
| `pnpm test` | Vitest (coming soon) |

## Project Structure
- `app/` – route segments (`/lists`, `/focus`, `/wins`).
- `components/` – reusable UI + feature components.
- `lib/api-client.ts` – API contract (Zod schemas + fetch wrapper).
- `lib/db.ts` – IndexedDB helpers for offline caching.
- `lib/store.ts` – Zustand global store (persisted via `localStorage`).

## Roadmap Snapshot (see `docs/web_development_roadmap.md`)
1. Align API client with `/v1/focus-card` and `/v1/anti-todo?date=`.
2. Hook IndexedDB cache + sync queue into React Query flows.
3. Add optimistic updates and toasts for mutations.
4. Support light/dark theme toggle instead of hardcoded dark mode.
5. Add unit/integration tests (Vitest + Playwright).

Contributions should reference a roadmap task and include updated tests/docs.
