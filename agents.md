# Agent Execution Guide

## Context
Andre is a productivity platform rooted in Marc Andreessen’s three-list methodology (Todo, Watch, Later) with nightly focus cards, Anti-Todo reflections, and structured procrastination coaching. Agents collaborating on this repo must preserve that philosophy while expanding functionality.

## Core responsibilities
1. Maintain parity between iOS and web feature sets by sharing domain models and API contracts.
2. Keep the nightly ritual sacred—ensure every change supports easy preparation of the next day’s 3–5 focus items.
3. Reinforce momentum by tracking Anti-Todo entries and surfacing structured procrastination wins.
4. Guard user trust through robust syncing, conflict resolution, and observability.

## Workflow expectations
- **Backlog hygiene**: Prioritize work through the three-list lens (Must/Watch/Later) using issues and labels.
- **Branching**: Use trunk-based development with short-lived branches (e.g., `feature/focus-card-generator`).
- **Testing**: Maintain fast unit tests (`services/api/tests`, `apps/ios/AndreApp/Tests`) and add contract tests for shared schemas.
- **Docs first**: Update `docs/` before implementation when requirements shift.
- **Agent hand-offs**: Summarize state, blockers, and next steps in PR descriptions to enable asynchronous agent collaboration.

## Definition of done
- Code compiled/linted, tests updated and passing.
- Telemetry or logs added for new user-facing flows.
- Documentation updated (README, docs, API specs).
- Rollout/rollback procedures captured in PR checklist.

## Coordination with FE/UI agent
- Share API schema updates in advance (OpenAPI snapshots in `services/api`).
- Provide SwiftUI view models and TypeScript types for front-end integration.
- Integrate design tokens delivered from `docs/fe_ui_agent_plan.md`.

## Command center
- Run `pnpm dev` in `services/api` for local backend.
- Use `Package.swift` + Xcode preview for iOS modules (once Xcode project is generated).
- Scripts will live in `scripts/` as automation tasks evolve.
- Hit `GET /v1/suggestions/structured-procrastination` to preview structured procrastination recommendations.
