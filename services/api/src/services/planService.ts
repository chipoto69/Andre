import { type ListItem } from "../domain/listItem.js";
import {
  AntiTodoEntry,
  AntiTodoEntrySchema,
  DailyFocusCard,
  DailyFocusCardSchema,
  GenerateFocusCardPayloadSchema
} from "../domain/focusCard.js";
import { ListRepository } from "../infra/listRepository.js";
import { FocusCardRepository } from "../infra/focusCardRepository.js";
import { AntiTodoRepository } from "../infra/antiTodoRepository.js";
import { BoardSchema, type BoardSnapshot } from "./listService.js";

export class PlanService {
  constructor(
    private readonly lists: ListRepository,
    private readonly focusCards: FocusCardRepository,
    private readonly antiTodo: AntiTodoRepository
  ) {}

  async generateFocusCard(payload: unknown): Promise<DailyFocusCard> {
    const parsed = GenerateFocusCardPayloadSchema.parse(payload);
    const board = BoardSchema.parse(this.lists.boardSnapshot());
    const suggestions = this.selectFocusItems(board);

    const focusCard: DailyFocusCard = {
      id: crypto.randomUUID(),
      date: parsed.date,
      items: suggestions,
      meta: {
        theme: this.deriveTheme(suggestions),
        energyBudget: this.estimateEnergy(suggestions),
        successMetric: `Complete ${suggestions.length} focus items`
      }
    };

    return this.focusCards.upsert(focusCard);
  }

  async getFocusCard(date: string): Promise<DailyFocusCard | null> {
    return this.focusCards.findByDate(date);
  }

  async saveFocusCard(payload: unknown): Promise<DailyFocusCard> {
    const parsed = DailyFocusCardSchema.parse(payload);
    return this.focusCards.upsert(parsed);
  }

  async logAntiTodo(payload: unknown): Promise<AntiTodoEntry> {
    const parsed = AntiTodoEntrySchema.parse(payload);
    return this.antiTodo.log(parsed);
  }

  private selectFocusItems(board: BoardSnapshot): ListItem[] {
    const prioritized = [
      ...board.todo.filter((item) => item.status !== "completed"),
      ...board.watch.filter((item) => item.followUpAt)
    ].sort((a, b) => {
      const dueDiff =
        (a.dueAt ? new Date(a.dueAt).getTime() : Number.MAX_SAFE_INTEGER) -
        (b.dueAt ? new Date(b.dueAt).getTime() : Number.MAX_SAFE_INTEGER);
      if (dueDiff !== 0) return dueDiff;

      const followUpDiff =
        (a.followUpAt ? new Date(a.followUpAt).getTime() : Number.MAX_SAFE_INTEGER) -
        (b.followUpAt ? new Date(b.followUpAt).getTime() : Number.MAX_SAFE_INTEGER);
      return dueDiff || followUpDiff;
    });

    return prioritized.slice(0, 5);
  }

  private deriveTheme(items: ListItem[]): string {
    if (items.length === 0) return "Momentum";
    const keywords = new Set<string>();

    for (const item of items) {
      const [firstWord] = item.title.split(" ");
      if (firstWord) {
        keywords.add(firstWord.toLowerCase());
      }
      if (keywords.size >= 2) break;
    }

    const phrase = Array.from(keywords)
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(" & ");

    return phrase || "Momentum";
  }

  private estimateEnergy(items: ListItem[]): DailyFocusCard["meta"]["energyBudget"] {
    if (items.length <= 3) return "medium";
    if (items.length >= 5) return "high";
    return "low";
  }
}
