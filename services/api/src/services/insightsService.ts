import { BoardSchema, type BoardSnapshot } from "./listService.js";
import { ListRepository } from "../infra/listRepository.js";
import {
  UserInsights,
  UserInsightsSchema,
  CompletionPatterns,
  ListHealth,
  InsightSuggestion
} from "../domain/userInsights.js";

type CompletionBucket = "morning" | "afternoon" | "evening";

export class InsightsService {
  constructor(
    private readonly lists: ListRepository
  ) {}

  generate(_userId: string): UserInsights {
    const board = BoardSchema.parse(this.lists.boardSnapshot());
    const allItems = [...board.todo, ...board.watch, ...board.later];
    const completionPatterns = this.calculateCompletionPatterns(allItems);
    const listHealth = this.calculateListHealth(board);
    const suggestions = this.buildSuggestions(completionPatterns, listHealth);

    return UserInsightsSchema.parse({
      completionPatterns,
      listHealth,
      suggestions
    });
  }

  private calculateCompletionPatterns(items: BoardSnapshot["todo"]): CompletionPatterns {
    const completedItems = items.filter((item) => item.completedAt);
    const completionTotals = items.length;
    const completionRate =
      completionTotals === 0 ? 0 : completedItems.length / Math.max(1, completionTotals);

    const dayFrequency = new Map<string, number>();
    const timeOfDayFrequency: Record<CompletionBucket, number> = {
      morning: 0,
      afternoon: 0,
      evening: 0
    };

    const completionDates = new Set<string>();

    for (const item of completedItems) {
      if (!item.completedAt) continue;
      const completedDate = new Date(item.completedAt);
      if (Number.isNaN(completedDate.getTime())) continue;

      const dayName = completedDate.toLocaleDateString("en-US", { weekday: "long" });
      dayFrequency.set(dayName, (dayFrequency.get(dayName) ?? 0) + 1);

      const hour = completedDate.getHours();
      const bucket: CompletionBucket = hour < 12 ? "morning" : hour < 17 ? "afternoon" : "evening";
      timeOfDayFrequency[bucket] += 1;

      completionDates.add(completedDate.toISOString().slice(0, 10));
    }

    const bestDayOfWeek =
      [...dayFrequency.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ?? "Tuesday";
    const bestTimeOfDay =
      (Object.entries(timeOfDayFrequency).sort((a, b) => b[1] - a[1])[0]?.[0] as CompletionBucket) ??
      "afternoon";

    const streak = this.calculateCompletionStreak(completionDates);

    return {
      bestDayOfWeek,
      bestTimeOfDay,
      averageCompletionRate: Number(completionRate.toFixed(2)),
      streak
    };
  }

  private calculateCompletionStreak(completionDates: Set<string>): number {
    if (completionDates.size === 0) return 0;

    let streak = 0;
    let cursor = new Date();
    cursor.setHours(0, 0, 0, 0);

    while (completionDates.has(cursor.toISOString().slice(0, 10))) {
      streak += 1;
      cursor.setDate(cursor.getDate() - 1);
    }

    return streak;
  }

  private calculateListHealth(board: BoardSnapshot): ListHealth {
    const now = Date.now();
    const todoStale = board.todo.filter((item) => {
      if (item.completedAt) return false;
      const createdAt = Date.parse(item.createdAt);
      return !Number.isNaN(createdAt) && now - createdAt > 7 * 24 * 60 * 60 * 1000;
    });

    const laterStale = board.later.filter((item) => {
      const createdAt = Date.parse(item.createdAt);
      return !Number.isNaN(createdAt) && now - createdAt > 30 * 24 * 60 * 60 * 1000;
    });

    const watchAvgDwell =
      board.watch.length === 0
        ? 0
        : board.watch.reduce((total, item) => {
            const createdAt = Date.parse(item.createdAt);
            if (Number.isNaN(createdAt)) return total;
            const dwellMs = now - createdAt;
            return total + dwellMs / (1000 * 60 * 60 * 24);
          }, 0) / board.watch.length;

    return {
      todo: {
        count: board.todo.length,
        staleItems: todoStale.length
      },
      watch: {
        count: board.watch.length,
        avgDwellTime: Number(watchAvgDwell.toFixed(1))
      },
      later: {
        count: board.later.length,
        staleItems: laterStale.length
      }
    };
  }

  private buildSuggestions(
    completionPatterns: CompletionPatterns,
    listHealth: ListHealth
  ): InsightSuggestion[] {
    const suggestions: InsightSuggestion[] = [];

    if (completionPatterns.averageCompletionRate >= 0.7) {
      suggestions.push({
        type: "encouragement",
        message: `${completionPatterns.streak}-day streak! You're building serious momentum 🔥`,
        actionable: false
      });
    } else {
      suggestions.push({
        type: "insight",
        message: `You complete more items on ${completionPatterns.bestDayOfWeek}s — plan deep work then.`,
        actionable: true
      });
    }

    if (listHealth.todo.staleItems > 0) {
      suggestions.push({
        type: "warning",
        message: `${listHealth.todo.staleItems} Todo item(s) have been idle for over a week.`,
        actionable: true
      });
    }

    if (listHealth.watch.avgDwellTime > 3) {
      suggestions.push({
        type: "insight",
        message: `Watch items stay about ${listHealth.watch.avgDwellTime} days — consider nudging blockers.`,
        actionable: true
      });
    }

    if (listHealth.later.staleItems > 5) {
      suggestions.push({
        type: "warning",
        message: `Later list is piling up (${listHealth.later.staleItems} older ideas). Time for a prune?`,
        actionable: true
      });
    }

    if (suggestions.length === 0) {
      suggestions.push({
        type: "encouragement",
        message: "Lists look balanced — keep shipping!",
        actionable: false
      });
    }

    return suggestions.slice(0, 3);
  }
}
