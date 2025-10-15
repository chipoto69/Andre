import {
  AntiTodoEntry,
  AntiTodoEntrySchema,
  DailyFocusCard,
  DailyFocusCardSchema,
  FocusCandidateItem,
  FocusCardContext,
  FocusCardSuggestion,
  FocusCardSuggestionSchema,
  GenerateFocusCardRequestSchema,
  IsoDateSchema
} from "../domain/focusCard.js";
import { ListRepository } from "../infra/listRepository.js";
import { FocusCardRepository } from "../infra/focusCardRepository.js";
import { AntiTodoRepository } from "../infra/antiTodoRepository.js";
import { BoardSchema } from "./listService.js";

export class PlanService {
  constructor(
    private readonly lists: ListRepository,
    private readonly focusCards: FocusCardRepository,
    private readonly antiTodo: AntiTodoRepository
  ) {}

  async generateFocusCardSuggestions(payload: unknown): Promise<FocusCardSuggestion> {
    const parsed = GenerateFocusCardRequestSchema.parse(payload);
    const candidates = parsed.availableItems ?? this.extractCandidatesFromBoard();
    const ranked = this.rankCandidates(candidates, parsed.targetDate);
    const targetSelectionCount =
      ranked.length === 0 ? 0 : Math.min(5, Math.max(3, ranked.length));
    const selected = ranked.slice(0, targetSelectionCount === 0 ? ranked.length : targetSelectionCount);

    const theme = this.deriveTheme(selected);
    const energyBudget = this.estimateEnergy(selected, parsed.context);
    const successMetric = this.buildSuccessMetric(selected);
    const reasoning = this.buildReasoning(selected, parsed.targetDate, parsed.context, theme);

    const suggestion = FocusCardSuggestionSchema.parse({
      suggestedItems: selected.map((item) => item.id),
      theme,
      energyBudget,
      successMetric,
      reasoning
    });

    if (suggestion.suggestedItems.length === 0) {
      return FocusCardSuggestionSchema.parse({
        suggestedItems: [],
        theme: "Plan a single win",
        energyBudget,
        successMetric: "Review your lists and pick one focus item",
        reasoning: {
          itemSelection:
            "No actionable items were provided. Prompting user to select at least one focus task.",
          themeRationale: "Focus on identifying the most meaningful next win.",
          energyEstimate:
            "Using default energy guidance because calendar and history data were insufficient."
        }
      });
    }

    return suggestion;
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

  async listAntiTodoEntries(date: string): Promise<AntiTodoEntry[]> {
    const parsedDate = IsoDateSchema.parse(date);
    const dayStart = startOfDayISO(parsedDate);
    const dayEnd = endOfDayISO(parsedDate);
    return this.antiTodo.listByDateRange(dayStart, dayEnd);
  }

  private extractCandidatesFromBoard(): FocusCandidateItem[] {
    const board = BoardSchema.parse(this.lists.boardSnapshot());
    return [
      ...board.todo,
      ...board.watch,
      ...board.later
    ].map((item) => ({
      id: item.id,
      title: item.title,
      listType: item.listType,
      dueAt: item.dueAt,
      priority: item.listType === "todo" ? 4 : item.listType === "watch" ? 3 : 2
    }));
  }

  private rankCandidates(items: FocusCandidateItem[], targetDate: string): FocusCandidateItem[] {
    return [...items].sort((a, b) => this.scoreCandidate(b, targetDate) - this.scoreCandidate(a, targetDate));
  }

  private scoreCandidate(item: FocusCandidateItem, targetDate: string): number {
    let score = item.priority ?? 3;
    if (item.listType === "todo") score += 2.5;
    if (item.listType === "watch") score += 1.5;
    if (item.listType === "later") score += 0.5;

    if (item.dueAt) {
      const dueDate = Date.parse(item.dueAt);
      const target = Date.parse(targetDate);
      if (!Number.isNaN(dueDate) && !Number.isNaN(target)) {
        const diffDays = Math.round((dueDate - target) / (1000 * 60 * 60 * 24));
        const urgencyWeight = diffDays < 0 ? 3 : 2;
        score += urgencyWeight / Math.max(1, Math.abs(diffDays));
      }
    }

    if (item.title.toLowerCase().includes("review") || item.title.toLowerCase().includes("send")) {
      score += 0.5;
    }

    return score;
  }

  private deriveTheme(items: FocusCandidateItem[]): string {
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

  private estimateEnergy(
    items: FocusCandidateItem[],
    context?: FocusCardContext
  ): DailyFocusCard["meta"]["energyBudget"] {
    if (context?.averageEnergyLevel) return context.averageEnergyLevel;

    const meetingMinutes = context?.calendarEvents?.reduce((total, event) => {
      const start = Date.parse(event.startTime);
      const end = Date.parse(event.endTime);
      if (Number.isNaN(start) || Number.isNaN(end) || end <= start) return total;
      return total + Math.floor((end - start) / (1000 * 60));
    }, 0);

    if (meetingMinutes !== undefined) {
      if (meetingMinutes >= 300) return "low";
      if (meetingMinutes >= 180) return "medium";
    }

    if (items.length >= 5) return "high";
    if (items.length <= 2) return "medium";
    return "medium";
  }

  private buildSuccessMetric(items: FocusCandidateItem[]): string {
    if (items.length === 0) {
      return "Review your lists and choose at least one priority task";
    }

    if (items.length === 1) {
      return `Ship "${items[0]?.title}" today`;
    }

    return `Complete ${items.length} focus ${items.length === 1 ? "item" : "items"}`;
  }

  private buildReasoning(
    items: FocusCandidateItem[],
    targetDate: string,
    context: FocusCardContext | undefined,
    theme: string
  ): FocusCardSuggestion["reasoning"] {
    const dueSoon = items.filter((item) => {
      if (!item.dueAt) return false;
      const diffDays = Math.round(
        (Date.parse(item.dueAt) - Date.parse(targetDate)) / (1000 * 60 * 60 * 24)
      );
      return !Number.isNaN(diffDays) && diffDays <= 2;
    });

    const listMix = new Set(items.map((item) => item.listType));

    const itemSelection =
      items.length === 0
        ? "No suggested items available; prompting manual selection."
        : dueSoon.length > 0
          ? `Prioritised ${dueSoon.length} item(s) with upcoming deadlines (${dueSoon
              .map((item) => item.title)
              .join(", ")}).`
          : `Selected highest-impact tasks across ${listMix.size} list type(s) to maintain momentum.`;

    const themeRationale =
      items.length === 0
        ? "Encouraging the user to craft their own focus theme."
        : `Theme "${theme}" generated from common phrasing across the chosen items.`;

    const meetingMinutes = context?.calendarEvents?.reduce((total, event) => {
      const start = Date.parse(event.startTime);
      const end = Date.parse(event.endTime);
      if (Number.isNaN(start) || Number.isNaN(end) || end <= start) return total;
      return total + Math.floor((end - start) / (1000 * 60));
    }, 0);

    const energyEstimate =
      context?.averageEnergyLevel !== undefined
        ? `Used stored energy preference (${context.averageEnergyLevel}) from previous completions.`
        : meetingMinutes !== undefined
          ? `Calendar density of ${meetingMinutes} minutes informed the energy guidance.`
          : "Defaulted to medium energy guidance due to limited context.";

    return {
      itemSelection,
      themeRationale,
      energyEstimate
    };
  }
}

function startOfDayISO(isoDate: string): string {
  const date = new Date(isoDate);
  date.setHours(0, 0, 0, 0);
  return date.toISOString();
}

function endOfDayISO(isoDate: string): string {
  const date = new Date(isoDate);
  date.setHours(23, 59, 59, 999);
  return date.toISOString();
}
