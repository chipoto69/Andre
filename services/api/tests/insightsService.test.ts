import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { connect, getDbInstance, resetDatabase } from "../src/infra/sqlite.js";
import { ListRepository } from "../src/infra/listRepository.js";
import { InsightsService } from "../src/services/insightsService.js";

describe("InsightsService", () => {
  let listRepo: ListRepository;
  let service: InsightsService;

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2025-10-16T12:00:00Z"));
    connect({ memory: true });
    resetDatabase();
    const db = getDbInstance();
    listRepo = new ListRepository(db);
    service = new InsightsService(listRepo);

    listRepo.upsert({
      title: "Finish project proposal",
      listType: "todo",
      status: "completed",
      createdAt: "2025-10-14T09:00:00Z",
      completedAt: "2025-10-16T10:00:00Z",
      tags: [],
      confidenceScore: 0.8
    });

    listRepo.upsert({
      title: "Review PR feedback",
      listType: "todo",
      status: "completed",
      createdAt: "2025-10-13T11:00:00Z",
      completedAt: "2025-10-15T14:30:00Z",
      tags: [],
      confidenceScore: 0.7
    });

    listRepo.upsert({
      title: "Draft retrospective notes",
      listType: "todo",
      status: "planned",
      createdAt: "2025-10-01T09:00:00Z",
      tags: [],
      confidenceScore: 0.4
    });

    listRepo.upsert({
      title: "Follow up with Sarah",
      listType: "watch",
      status: "planned",
      createdAt: "2025-10-08T16:00:00Z",
      tags: [],
      confidenceScore: 0.5
    });

    listRepo.upsert({
      title: "Explore calendar integrations",
      listType: "later",
      status: "planned",
      createdAt: "2025-08-15T09:00:00Z",
      tags: [],
      confidenceScore: 0.3
    });
  });

  it("produces insights derived from list activity", () => {
    const insights = service.generate("user-123");

    expect(insights.completionPatterns.averageCompletionRate).toBe(0.4);
    expect(insights.listHealth.todo.staleItems).toBe(1);
    expect(insights.listHealth.watch.avgDwellTime).toBeGreaterThan(3);
    expect(insights.suggestions.length).toBeGreaterThan(0);
    expect(insights.suggestions[0]?.message.length).toBeGreaterThan(0);
  });

  afterEach(() => {
    vi.useRealTimers();
  });
});
