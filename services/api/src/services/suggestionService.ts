import { z } from "zod";
import { type ListItem } from "../domain/listItem.js";
import { ListRepository } from "../infra/listRepository.js";
import { AntiTodoRepository } from "../infra/antiTodoRepository.js";
import { BoardSchema } from "./listService.js";
import { Suggestion, SuggestionListSchema } from "../domain/suggestion.js";

const ConfigSchema = z.object({
  limit: z.number().int().min(1).max(10).default(5)
});

export class SuggestionService {
  constructor(
    private readonly lists: ListRepository,
    private readonly antiTodo: AntiTodoRepository
  ) {}

  generateStructuredProcrastinationSuggestions(
    config: Partial<z.infer<typeof ConfigSchema>> = {}
  ): Suggestion[] {
    const { limit } = ConfigSchema.parse(config);
    const board = BoardSchema.parse(this.lists.boardSnapshot());

    const laterCandidates = board.later
      .filter((item) => item.status !== "completed" && item.status !== "archived")
      .map((item) => createSuggestionFromItem(item, "later"));

    const followUps = board.watch
      .filter((item) => item.status !== "archived")
      .sort((a, b) => {
        const aFollowUp = a.followUpAt
          ? new Date(a.followUpAt).getTime()
          : Number.MAX_SAFE_INTEGER;
        const bFollowUp = b.followUpAt
          ? new Date(b.followUpAt).getTime()
          : Number.MAX_SAFE_INTEGER;
        return aFollowUp - bFollowUp;
      })
      .map((item) =>
        createSuggestionFromItem(item, "watch", "Follow up to keep momentum alive.")
      );

    const momentumBoosters = this.antiTodo
      .listByDateRange(
        startOfDayISO(new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)),
        endOfDayISO(new Date())
      )
      .slice(0, 3)
      .map((entry) => ({
        id: `momentum-${entry.id}`,
        title: entry.title,
        description: "Build on a recent win by doubling down on what worked.",
        listType: "antiTodo" as const,
        score: 0.4,
        source: "momentum" as const
      }));

    const ranked = [...laterCandidates, ...followUps, ...momentumBoosters].sort(
      (a, b) => b.score - a.score
    );

    return SuggestionListSchema.parse(ranked.slice(0, limit));
  }
}

function createSuggestionFromItem(
  item: Pick<
    ListItem,
    "id" | "title" | "notes" | "listType" | "dueAt" | "followUpAt" | "tags"
  >,
  source: Suggestion["source"],
  fallbackDescription?: string
): Suggestion {
  const description =
    item.notes ??
    fallbackDescription ??
    (source === "later"
      ? "Quick win from the Later list to convert procrastination into progress."
      : "Follow-up opportunity that keeps relationships warm.");

  const score = scoreItem(item, source);

  return {
    id: `${source}-${item.id}`,
    title: item.title,
    description,
    listType: item.listType,
    score,
    source
  };
}

function scoreItem(
  item: Pick<ListItem, "dueAt" | "followUpAt" | "tags">,
  source: Suggestion["source"]
): number {
  const now = Date.now();
  let score = 0.5;

  if (source === "later") {
    const urgencyBoost = item.dueAt ? urgencyWeight(new Date(item.dueAt).getTime(), now) : 0.1;
    score += urgencyBoost;
  }

  if (source === "watch") {
    const followUpBoost = item.followUpAt
      ? urgencyWeight(new Date(item.followUpAt).getTime(), now)
      : 0.2;
    score += followUpBoost;
  }

  if (item.tags?.includes("quick") || item.tags?.includes("low-effort")) {
    score += 0.15;
  }

  return Math.min(1, score);
}

function urgencyWeight(target: number, now: number): number {
  const diff = target - now;
  if (diff <= 0) return 0.4;
  const days = diff / (24 * 60 * 60 * 1000);
  if (days <= 1) return 0.3;
  if (days <= 3) return 0.2;
  if (days <= 7) return 0.1;
  return 0.05;
}

function startOfDayISO(date: Date): string {
  const copy = new Date(date);
  copy.setHours(0, 0, 0, 0);
  return copy.toISOString();
}

function endOfDayISO(date: Date): string {
  const copy = new Date(date);
  copy.setHours(23, 59, 59, 999);
  return copy.toISOString();
}
