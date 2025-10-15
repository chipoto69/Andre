## Andre Web Frontend

Implementation deferred to the dedicated FE/UI agent. Key expectations:
- Stack recommendation: Remix (React) + TypeScript + Tailwind + Zustand.
- Consume API contracts from `services/api` (shared types via OpenAPI).
- Support responsive breakpoints (mobile, tablet, desktop) and offline caching (IndexedDB).
- Mirror rituals: nightly planning wizard, Anti-Todo timeline, structured procrastination suggestions.
- Implement theming + design tokens per `docs/fe_ui_agent_plan.md`.

### Preparation checklist
1. Generate API client via `pnpm openapi` (to be added).
2. Establish routing: `/focus`, `/lists`, `/anti-todo`, `/settings`.
3. Provide Storybook stories for all interactive components.
4. Ensure keyboard navigation and a11y compliance.
