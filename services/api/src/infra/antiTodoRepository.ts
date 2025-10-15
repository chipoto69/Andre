import { type Database } from "better-sqlite3";
import { AntiTodoEntry, AntiTodoEntrySchema } from "../domain/focusCard.js";

export class AntiTodoRepository {
  constructor(private readonly db: Database) {}

  log(entry: AntiTodoEntry): AntiTodoEntry {
    const persisted = {
      id: entry.id ?? crypto.randomUUID(),
      title: entry.title,
      completedAt: entry.completedAt ?? new Date().toISOString()
    };

    this.db
      .prepare(
        `
        INSERT INTO anti_todo_entries (id, title, completed_at)
        VALUES (@id, @title, @completedAt)
      `
      )
      .run(persisted);

    return AntiTodoEntrySchema.parse(persisted);
  }

  listByDateRange(startIso: string, endIso: string): AntiTodoEntry[] {
    const rows = this.db
      .prepare(
        `
        SELECT * FROM anti_todo_entries
        WHERE completed_at BETWEEN ? AND ?
        ORDER BY completed_at DESC
      `
      )
      .all(startIso, endIso) as Record<string, unknown>[];

    return rows.map((row) =>
      AntiTodoEntrySchema.parse({
        id: row.id,
        title: row.title,
        completedAt: row.completed_at
      })
    );
  }
}
