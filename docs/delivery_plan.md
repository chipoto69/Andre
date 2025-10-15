# Delivery Roadmap (Q1 2026)

This roadmap reflects the current codebase reality and prioritises the highest-risk gaps observed in the latest audit.
It supersedes the earlier phase-based outline.

---

## 0. Security & Platform Foundations (Blocking)
| Area | Goal | Tasks | Ownership |
|---|---|---|---|
| **Backend auth** | Protect every API call with authenticated, user-scoped access. | - Introduce session/token validation middleware.<br>- Add `user_id` columns to `list_items`, `focus_cards`, `anti_todo_entries`.<br>- Update repositories & routes to enforce per-user filtering.<br>- Provide local dev auth shim for agents. | Backend |
| **Schema management** | Enable safe DB evolution. | - Adopt a migration tool (e.g., Drizzle/Prisma).<br>- Create baseline migration for existing tables.<br>- Wire migrations into CI/startup scripts. | Backend / Infra |
| **Environment config** | Align service URLs + credentials across apps. | - Replace hardcoded `localhost:3000/3333` with environment-driven config for API, web, and iOS.<br>- Document `.env` samples for each surface.<br>- Ensure dev/test/prod configs live in source control templates. | Backend + Web + iOS |

---

## 1. Contract Alignment & Data Integrity
| Area | Goal | Tasks | Ownership |
|---|---|---|---|
| **API ⇄ clients** | Ensure all transports speak the same language. | - Update backend focus + anti-todo routes to support REST resources (`/v1/focus-card`, `/v1/anti-todo?date=`) with canonical responses.<br>- Patch web `api-client.ts` to match server endpoints (board, focus card, anti-todo, suggestions).<br>- Update iOS `SyncService` & DTOs to reuse server responses for round trips (create/update list items, anti-todo logging).<br>- Add contract tests (Vitest + Playwright/Swift tests) covering these flows. | Backend / Web / iOS |
| **Optimistic locking** | Prevent silent overwrites when multiple devices edit. | - Add `version`/`updated_at` columns server-side.<br>- Require version check on update/delete routes (409 on mismatch).<br>- Surface conflict errors nicely in iOS + web UI. | Backend (+ clients) |

---

## 2. Offline & Persistence Readiness
| Area | Goal | Tasks | Ownership |
|---|---|---|---|
| **iOS persistence** | Ship SwiftData-backed offline cache end to end. | - Finalise SwiftData entities + mappers (ListItemEntity, FocusCardEntity, AntiTodoEntryEntity, SyncQueueOperationEntity).<br>- Initialise `OfflineQueueProcessor` after onboarding; tie into `NetworkMonitor`.<br>- Add retry/backoff (already scaffolded) and confirm queue drains.<br>- Replace `fatalError` with recoverable initialisation errors + user messaging.<br>- Write unit tests for `LocalStore` and queue processor. | iOS |
| **Web offline mode** | Activate IndexedDB cache & sync queue. | - Hook `db.ts` into React Query fetch/mutation flows.<br>- Persist board/focus/anti-todo locally, fall back on cached data when offline.<br>- Flush queued mutations once network returns.<br>- Add integration tests (Vitest/Playwright) to validate offline/online transitions. | Web |

---

## 3. UX Polish & Feature Completeness
| Area | Goal | Tasks | Ownership |
|---|---|---|---|
| **Suggestions** | Make structured procrastination usable. | - Render `/v1/suggestions/structured-procrastination` results in iOS & web (view models already scaffolded).<br>- Track dismissal/acceptance metrics (backend events TBD). | Web + iOS + Backend |
| **Planning flows** | Smooth journey from list triage → focus card → wins. | - iOS: break `AndreApp.swift` into modular screens & inject view models.<br>- Web: ensure Planning Wizard shares state with lists and pre-selects planning items.<br>- Add friendly empty/error states and toasts for failures. | iOS + Web |
| **Theming & accessibility** | Support light mode + accessibility commitments. | - Replace hardcoded dark theme with system-aware theming (web & iOS).<br>- Audit components for contrast/keyboard navigation.<br>- Add basic accessibility tests (web) & VoiceOver pass (iOS). | Web + iOS |

---

## 4. Quality Engineering
| Area | Goal | Tasks | Ownership |
|---|---|---|---|
| **Automated tests** | Prevent regressions as agents iterate. | - Backend: expand Vitest coverage to route-level tests (lists/focus/anti-todo/suggestions).<br>- Web: add component + integration tests for `lists`, `focus`, `wins` pages (React Testing Library + Playwright).<br>- iOS: add unit tests for view models + snapshot tests for key views. | Backend / Web / iOS |
| **CI/CD** | Catch issues early. | - Configure GitHub Actions (or preferred runner) for lint/test/build per surface.<br>- Add branch protection requiring tests before merge. | Infra / DevEx |

---

## Cadence & Communication
- **Weekly sync**: review roadmap progress, unblock dependencies, recalibrate priorities.
- **Bi-weekly demo**: showcase end-to-end flows (lists → focus → wins, offline stories, suggestions).
- **Monthly retro**: cross-surface review of stability, developer experience, and user feedback.
