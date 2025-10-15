import { type Database } from "better-sqlite3";
import { DailyFocusCard, DailyFocusCardSchema } from "../domain/focusCard.js";
import { ListItemSchema } from "../domain/listItem.js";

export class FocusCardRepository {
  constructor(private readonly db: Database) {}

  upsert(card: DailyFocusCard): DailyFocusCard {
    const persisted = {
      ...card,
      id: card.id ?? crypto.randomUUID(),
      date: card.date,
      usedAiSuggestions: card.usedAiSuggestions ?? false
    };

    this.db
      .prepare(
        `
        INSERT INTO focus_cards (id, date, items, theme, energy_budget, success_metric, reflection, used_ai_suggestions)
        VALUES (@id, @date, @items, @theme, @energyBudget, @successMetric, @reflection, @usedAiSuggestions)
        ON CONFLICT(date) DO UPDATE SET
          items = excluded.items,
          theme = excluded.theme,
          energy_budget = excluded.energy_budget,
          success_metric = excluded.success_metric,
          reflection = excluded.reflection,
          used_ai_suggestions = excluded.used_ai_suggestions
      `
      )
      .run({
        ...persisted,
        items: JSON.stringify(persisted.items),
        usedAiSuggestions: persisted.usedAiSuggestions ? 1 : 0
      });

    return DailyFocusCardSchema.parse({
      ...persisted
    });
  }

  findByDate(date: string): DailyFocusCard | null {
    const row = this.db
      .prepare("SELECT * FROM focus_cards WHERE date = ?")
      .get(date) as Record<string, unknown> | undefined;

    if (!row) return null;

    const items = Array.isArray(row.items)
      ? row.items
      : JSON.parse((row.items as string) ?? "[]");

    return DailyFocusCardSchema.parse({
      id: row.id,
      date: row.date,
      items: items.map((item: unknown) => ListItemSchema.parse(item)),
      meta: {
        theme: row.theme ?? "",
        energyBudget: row.energy_budget ?? "medium",
        successMetric: row.success_metric ?? ""
      },
      usedAiSuggestions: Boolean(row.used_ai_suggestions),
      reflection: row.reflection ?? ""
    });
  }

  list(limit = 30): DailyFocusCard[] {
    const rows = this.db
      .prepare("SELECT * FROM focus_cards ORDER BY date DESC LIMIT ?")
      .all(limit) as Record<string, unknown>[];

    return rows.map((row) => this.findByDate(row.date as string)!).filter(Boolean);
  }
}
