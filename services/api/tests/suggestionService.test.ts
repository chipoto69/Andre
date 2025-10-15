import { beforeEach, describe, expect, it } from "vitest";
import { connect, resetDatabase, getDbInstance } from "../src/infra/sqlite.js";
import { ListRepository } from "../src/infra/listRepository.js";
import { AntiTodoRepository } from "../src/infra/antiTodoRepository.js";
import { SuggestionService } from "../src/services/suggestionService.js";

describe("SuggestionService", () => {
  let suggestionService: SuggestionService;
  let listRepo: ListRepository;
  let antiTodoRepo: AntiTodoRepository;

  beforeEach(() => {
    connect({ memory: true });
    resetDatabase();
    listRepo = new ListRepository(getDbInstance());
    antiTodoRepo = new AntiTodoRepository(getDbInstance());
    suggestionService = new SuggestionService(listRepo, antiTodoRepo);
  });

  it("prioritizes quick Later items and timely Watch follow-ups", () => {
    listRepo.upsert({
      title: "Quick experiment",
      listType: "later",
      dueAt: futureDate(2),
      tags: ["quick"]
    });

    listRepo.upsert({
      title: "Draft blog outline",
      listType: "later",
      dueAt: futureDate(5)
    });

    listRepo.upsert({
      title: "Check in with Sarah",
      listType: "watch",
      followUpAt: futureDate(1)
    });

    antiTodoRepo.log({
      title: "Shipped API schema",
      completedAt: futureDate(-1)
    });

    const suggestions =
      suggestionService.generateStructuredProcrastinationSuggestions({ limit: 5 });

    expect(suggestions).toHaveLength(4);
    expect(suggestions[0]?.title).toBe("Quick experiment");
    expect(suggestions[0]?.source).toBe("later");
    expect(suggestions.some((item) => item.source === "momentum")).toBe(true);
  });
});

function futureDate(offsetDays: number): string {
  const date = new Date();
  date.setDate(date.getDate() + offsetDays);
  return date.toISOString();
}
