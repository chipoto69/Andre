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
});
