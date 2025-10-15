import { type Database } from "better-sqlite3";
import { ListItem, ListItemSchema, NewListItem, UpdateListItem } from "../domain/listItem.js";

export class ListRepository {
  constructor(private readonly db: Database) {}

  upsert(item: NewListItem | ListItem): ListItem {
    const persisted = {
      ...item,
      id: item.id ?? crypto.randomUUID(),
      createdAt: item.createdAt ?? new Date().toISOString()
    };

    this.db
      .prepare(
        `
        INSERT INTO list_items (
          id, title, list_type, status, notes, due_at, follow_up_at,
          created_at, completed_at, tags, confidence_score
        ) VALUES (
          @id, @title, @listType, @status, @notes, @dueAt, @followUpAt,
          @createdAt, @completedAt, @tags, @confidenceScore
        )
        ON CONFLICT(id) DO UPDATE SET
          title = excluded.title,
          list_type = excluded.list_type,
          status = excluded.status,
          notes = excluded.notes,
          due_at = excluded.due_at,
          follow_up_at = excluded.follow_up_at,
          completed_at = excluded.completed_at,
          tags = excluded.tags,
          confidence_score = excluded.confidence_score
      `
      )
      .run({
        ...persisted,
        tags: JSON.stringify(persisted.tags ?? [])
      });

    return ListItemSchema.parse(persisted);
  }

  update(id: string, patch: UpdateListItem): ListItem | null {
    const existing = this.findById(id);
    if (!existing) return null;

    const merged = { ...existing, ...patch };
    return this.upsert(merged);
  }

  findById(id: string): ListItem | null {
    const row = this.db
      .prepare("SELECT * FROM list_items WHERE id = ?")
      .get(id) as Row | undefined;

    if (!row) return null;
    return ListItemSchema.parse(mapRow(row));
  }

  listByType(listType: ListItem["listType"]): ListItem[] {
    const rows = this.db
      .prepare("SELECT * FROM list_items WHERE list_type = ? ORDER BY created_at DESC")
      .all(listType) as Row[];

    return rows.map((row) => ListItemSchema.parse(mapRow(row)));
  }

  boardSnapshot(): Record<ListItem["listType"], ListItem[]> {
    const rows = this.db
      .prepare("SELECT * FROM list_items ORDER BY created_at DESC")
      .all() as Row[];

    return rows.reduce<Record<ListItem["listType"], ListItem[]>>((acc, row) => {
      const parsed = ListItemSchema.parse(mapRow(row));
      if (!acc[parsed.listType]) acc[parsed.listType] = [];
      acc[parsed.listType].push(parsed);
      return acc;
    }, { todo: [], watch: [], later: [], antiTodo: [] });
  }

  delete(id: string): void {
    this.db.prepare("DELETE FROM list_items WHERE id = ?").run(id);
  }
}

type Row = {
  id: string;
  title: string;
  list_type: string;
  status: string;
  notes?: string | null;
  due_at?: string | null;
  follow_up_at?: string | null;
  created_at: string;
  completed_at?: string | null;
  tags?: string | null;
  confidence_score?: number | null;
};

function parseTags(input: unknown): string[] {
  if (!input) return [];
  if (typeof input === "string") {
    try {
      const parsed = JSON.parse(input);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  if (Array.isArray(input)) return input as string[];
  return [];
}

function mapRow(row: Row) {
  return {
    id: row.id,
    title: row.title,
    listType: row.list_type as ListItem["listType"],
    status: row.status as ListItem["status"],
    notes: row.notes ?? undefined,
    dueAt: row.due_at ?? undefined,
    followUpAt: row.follow_up_at ?? undefined,
    createdAt: row.created_at,
    completedAt: row.completed_at ?? undefined,
    tags: parseTags(row.tags),
    confidenceScore: row.confidence_score ?? 0.5
  };
}
