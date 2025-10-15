# Web Frontend Roadmap (Q1 2026)

## Mission
Ship a Next.js 15 web client that stays in lockstep with the backend/iOS contracts, supports offline usage via IndexedDB, and delivers parity across focus, lists, wins, and suggestions.

---

## 1. API Contract Alignment (Now)
- [ ] Update `lib/api-client.ts` to use canonical endpoints:
  - `/v1/lists/sync`, `/v1/lists/:id`
  - `/v1/focus-card?date=YYYY-MM-DD` (GET) and `/v1/focus-card` (PUT/POST)
  - `/v1/anti-todo?date=` (GET) + `/v1/anti-todo` (POST)
  - `/v1/suggestions/structured-procrastination?limit=`
- [ ] Return server payloads from mutations and hydrate React Query cache accordingly.
- [ ] Default `NEXT_PUBLIC_API_URL` to match backend port (3333) and document required env vars.

## 2. Offline & Sync
- [ ] Wire `lib/db.ts` into the data layer: cache board/focus/wins, serve cached data when offline, enqueue mutations in `syncQueue`.
- [ ] Implement background flush logic that retries queued ops when navigator goes online.
- [ ] Provide optimistic updates with rollback for list item CRUD and win logging.

## 3. UX & Theming
- [ ] Replace hardcoded dark theme with system-aware theming (track preference in Zustand/local storage).
- [ ] Polish empty/error states for Lists, Focus, Wins, Suggestions pages with consistent alert components.
- [ ] Add toasts/snackbars for mutation success/failure.

## 4. Ritual Flows Completion
- [ ] Planning mode: ensure selection state persists between Lists page and Planning Wizard.
- [ ] Suggestions tab: surface `/v1/suggestions/structured-procrastination` results with filtering and “snooze”/“accept” affordances.
- [ ] Wins timeline: support filtering by date range and quick-add modal with validation.

## 5. Quality & Tooling
- [ ] Add unit tests with Vitest/React Testing Library for key components (ListBoard, PlanningWizard, FocusCard, WinTimeline).
- [ ] Add Playwright smoke tests covering navigation (home → lists → focus → wins) and offline fallback.
- [ ] Integrate ESLint/Prettier into CI; fail builds on lint/test errors.
- [ ] Document local setup (`pnpm install`, required env vars, running tests) in `apps/web/frontend/README.md`.

## Backlog / Later
- Calendar integrations (sync events to suggestions/planning).
- Collaboration features (shared boards, notifications).
- Advanced analytics dashboards once backend telemetry is available.
