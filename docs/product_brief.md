# Product Brief — Andre

## Problem & opportunity
Knowledge workers drown in scattered obligations, follow-ups, and aspirational ideas. Traditional apps over-index on task capture without strengthening the nightly planning ritual or celebrating the work we actually complete. Marc Andreessen’s three-list system provides a crisp blueprint for focus and momentum. Andre operationalizes that blueprint across iOS and the web while honoring the tactile satisfaction of the 3x5 card.

## Target users
- Individual contributors juggling varied commitments (product, engineering, design, consulting).
- Founders and operators coordinating teams across asynchronous time zones.
- Knowledge workers seeking a lightweight but disciplined personal operating system.

## Jobs to be done
1. Capture everything that matters into three canonical lists (Todo, Watch, Later) without friction.
2. Each evening, translate priority items into a tight, achievable focus card for the next day.
3. Track real-world progress throughout the day via the Anti-Todo ledger and celebrate the wins.
4. Harness structured procrastination by bubbling up context-aware “productive distraction” options.
5. Stay in sync across devices with confident offline support and minimal overhead.

## Key user promises
- **Focus**: “I know exactly what deserves my attention today.”
- **Momentum**: “I see tangible proof of progress and can adjust quickly.”
- **Trust**: “Nothing slips because every obligation lives on one of three lists.”
- **Flow**: “Switching contexts between devices is seamless.”

## Experience pillars
- **Guided ritual**: Subtle coaching for nightly focus planning and end-of-day reflection.
- **Ambient intelligence**: Smart suggestions powered by heuristics, streaks, and historical patterns.
- **Calm aesthetics**: Front-end will be handled by a dedicated UI agent to deliver a spaced, legible design with gentle animations and haptics on iOS.
- **Extensibility**: APIs and shared domain models enable future integrations with calendar, email, and messaging platforms.

## Success metrics (v1 → v2)
- **Activation**: 70% of new users complete two consecutive focus cards in their first week.
- **Retention**: Weekly actives maintain ≥4 Anti-Todo entries per week by week four.
- **Engagement**: 50% of daily sessions include at least one structured procrastination suggestion.
- **Reliability**: <0.1% sync conflicts, p95 API latency under 150ms for list operations.

## Release milestones
1. **Foundational (Weeks 0-4)** — Stand up core domain models, API, local persistence, iOS prototype with manual triage workflow.
2. **Ritual (Weeks 5-8)** — Implement nightly planning, Anti-Todo ledger, analytics snapshots, notifications.
3. **Intelligence (Weeks 9-12)** — Suggestion engine, structured procrastination playbook, calendar integration, push/pull sync.
4. **Expansion (Post v1)** — Public API, collaboration features, integrations (Slack, email, Siri Shortcuts).

## Dependencies & risks
- Generating the SwiftUI app structure requires Xcode project scaffolding; pending once UI agent designs flows and components.
- Sync complexity across mobile and web demands a well-designed conflict strategy; we default to CRDT-like merge rules for lists.
- Motivation loops depend on approachable visuals—close collaboration with the FE/UI agent is mandatory to deliver the right “feel.”

## Next steps
- Finalize API contracts and shared domain models (`services/api/src/domain`).
- Build core persistence layer leveraging SQLite locally and plan PostgreSQL migrations.
- Enable background task scheduling on iOS via Swift concurrency once UI skeleton lands.
- Deliver FE/UI agent with componentry spec, color tokens, and interaction blueprint (see `docs/fe_ui_agent_plan.md`).
- Wire mobile/web clients to the structured procrastination suggestions API and Anti-Todo daily summaries once UI shells exist.
