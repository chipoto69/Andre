import { beforeEach, describe, expect, it } from "vitest";
import { connect, resetDatabase, getDbInstance } from "../src/infra/sqlite.js";
import { ListRepository } from "../src/infra/listRepository.js";
import { FocusCardRepository } from "../src/infra/focusCardRepository.js";
import { AntiTodoRepository } from "../src/infra/antiTodoRepository.js";
import { PlanService } from "../src/services/planService.js";

describe("PlanService", () => {
  let planService: PlanService;
  let listRepo: ListRepository;
  let antiTodoRepo: AntiTodoRepository;

  beforeEach(() => {
    connect({ memory: true });
    resetDatabase();
    const db = getDbInstance();
    listRepo = new ListRepository(db);
    antiTodoRepo = new AntiTodoRepository(db);
    const focusRepo = new FocusCardRepository(db);
    planService = new PlanService(listRepo, focusRepo, antiTodoRepo);
  });

  it("returns Anti-Todo entries for a given date", async () => {
    await planService.logAntiTodo({
      title: "Published release notes",
      completedAt: "2024-01-01T10:15:00.000Z"
    });

    await planService.logAntiTodo({
      title: "Filed expenses",
      completedAt: "2024-01-02T08:00:00.000Z"
    });

    const entries = await planService.listAntiTodoEntries("2024-01-01");
    expect(entries).toHaveLength(1);
    expect(entries[0]?.title).toBe("Published release notes");
  });

  it("generates focus card suggestions from provided items", async () => {
    const result = await planService.generateFocusCardSuggestions({
      userId: "user-123",
      targetDate: "2025-10-16",
      availableItems: [
        {
          id: "item-1",
          title: "Finish project proposal",
          listType: "todo",
          dueAt: "2025-10-17T10:00:00Z",
          priority: 5
        },
        {
          id: "item-2",
          title: "Review PR from Sarah",
          listType: "todo",
          dueAt: "2025-10-16T15:00:00Z",
          priority: 4
        },
        {
          id: "item-3",
          title: "Follow up on partnership",
          listType: "watch",
          dueAt: "2025-10-18T12:00:00Z",
          priority: 3
        }
      ],
      context: {
        calendarEvents: [
          {
            title: "Team standup",
            startTime: "2025-10-16T09:00:00Z",
            endTime: "2025-10-16T09:30:00Z"
          },
          {
            title: "Client call",
            startTime: "2025-10-16T14:00:00Z",
            endTime: "2025-10-16T15:00:00Z"
          }
        ],
        historicalCompletionRate: 0.78
      }
    });

    expect(result.suggestedItems).toHaveLength(3);
    expect(result.theme.length).toBeGreaterThan(0);
    expect(result.energyBudget).toBe("medium");
    expect(result.reasoning.itemSelection).toContain("Prioritised");
  });

  it("persists focus card metadata including AI usage", async () => {
    const listItem = listRepo.upsert({
      title: "Ship marketing launch email",
      listType: "todo",
      status: "planned",
      createdAt: "2025-10-14T09:15:00Z",
      tags: []
    });

    const saved = await planService.saveFocusCard({
      id: "00000000-0000-0000-0000-000000000000",
      date: "2025-10-16",
      items: [listItem],
      meta: {
        theme: "Launch readiness",
        energyBudget: "medium",
        successMetric: "Send launch email"
      },
      usedAiSuggestions: true
    });

    expect(saved.usedAiSuggestions).toBe(true);

    const fetched = await planService.getFocusCard("2025-10-16");
    expect(fetched?.usedAiSuggestions).toBe(true);
  });
});
