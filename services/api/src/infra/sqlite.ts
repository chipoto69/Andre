import path from "node:path";
import fs from "node:fs";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);

type BetterSqlite3Module = typeof import("better-sqlite3");
let BetterSqlite3: BetterSqlite3Module | null = null;

try {
  BetterSqlite3 = require("better-sqlite3") as BetterSqlite3Module;
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  console.warn(
    `[sqlite] Falling back to in-memory adapter because better-sqlite3 failed to load: ${message}`
  );
}

const DEFAULT_DB_PATH = path.join(process.cwd(), "andre.db");

export interface SQLiteConfig {
  filename?: string;
  memory?: boolean;
}

type DatabaseLike = BetterSqlite3Module extends null
  ? InMemoryDatabase
  : BetterSqlite3Module["Database"] | InMemoryDatabase;

let db: DatabaseLike | null = null;

export function connect(config: SQLiteConfig = {}): DatabaseLike {
  if (db) return db;

  const filename = config.memory ? ":memory:" : config.filename ?? DEFAULT_DB_PATH;
  if (filename !== ":memory:") {
    const dir = path.dirname(filename);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  }

  if (BetterSqlite3) {
    try {
      db = new BetterSqlite3(filename);
      db.pragma?.("journal_mode = WAL");
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.warn(
        `[sqlite] Failed to initialise better-sqlite3 ("${message}"). Falling back to in-memory adapter.`
      );
      db = new InMemoryDatabase();
    }
  } else {
    db = new InMemoryDatabase();
  }

  initialiseSchema(db);
  return db;
}

function initialiseSchema(database: DatabaseLike) {
  database
    .prepare(`
      CREATE TABLE IF NOT EXISTS list_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        list_type TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        due_at TEXT,
        follow_up_at TEXT,
        created_at TEXT NOT NULL,
        completed_at TEXT,
        tags TEXT,
        confidence_score REAL DEFAULT 0.5
      )
    `)
    .run();

  database
    .prepare(`
      CREATE TABLE IF NOT EXISTS focus_cards (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        items TEXT NOT NULL,
        theme TEXT,
        energy_budget TEXT,
        success_metric TEXT,
        reflection TEXT,
        used_ai_suggestions INTEGER DEFAULT 0
      )
    `)
    .run();
  ensureColumn(database, "focus_cards", "used_ai_suggestions", "INTEGER DEFAULT 0");

  database
    .prepare(`
      CREATE TABLE IF NOT EXISTS anti_todo_entries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    `)
    .run();

  database
    .prepare(`
      CREATE TABLE IF NOT EXISTS user_preferences (
        user_id TEXT PRIMARY KEY,
        planning_time TEXT NOT NULL DEFAULT 'evening',
        planning_hour INTEGER,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        timezone TEXT NOT NULL DEFAULT 'UTC',
        onboarding_completed_at TEXT,
        onboarding_version TEXT NOT NULL DEFAULT '3.0'
      )
    `)
    .run();
}

export function resetDatabase() {
  if (!db) return;
  db.exec?.("DELETE FROM list_items");
  db.exec?.("DELETE FROM focus_cards");
  db.exec?.("DELETE FROM anti_todo_entries");
  db.exec?.("DELETE FROM user_preferences");
}

export function getDbInstance(): DatabaseLike {
  if (!db) {
    throw new Error("SQLite not connected. Call connect() first.");
  }
  return db;
}

function ensureColumn(
  database: DatabaseLike,
  table: string,
  columnName: string,
  columnDefinition: string
) {
  const existingColumns = database
    .prepare(`PRAGMA table_info(${table})`)
    .all() as Array<{ name: string }>;

  if (!existingColumns.some((column) => column.name === columnName)) {
    database
      .prepare(`ALTER TABLE ${table} ADD COLUMN ${columnName} ${columnDefinition}`)
      .run();
  }
}

type TableName =
  | "list_items"
  | "focus_cards"
  | "anti_todo_entries"
  | "user_preferences";

type StatementResult = {
  run: (bindings?: unknown) => { changes: number };
  get: (...bindings: unknown[]) => Record<string, unknown> | undefined;
  all: (...bindings: unknown[]) => Record<string, unknown>[];
};

class InMemoryDatabase {
  private readonly tables: Record<TableName, Map<string, Record<string, unknown>>> = {
    list_items: new Map(),
    focus_cards: new Map(),
    anti_todo_entries: new Map(),
    user_preferences: new Map()
  };

  prepare(sql: string): StatementResult {
    const normalized = normalize(sql);

    if (normalized.startsWith("CREATE TABLE")) {
      return noopStatement();
    }

    if (normalized.startsWith("INSERT INTO LIST_ITEMS")) {
      return {
        run: (bindings?: Record<string, any>) => {
          const params = bindings ?? {};
          const row = {
            id: params.id,
            title: params.title,
            list_type: params.listType,
            status: params.status,
            notes: params.notes ?? null,
            due_at: params.dueAt ?? null,
            follow_up_at: params.followUpAt ?? null,
            created_at: params.createdAt,
            completed_at: params.completedAt ?? null,
            tags: params.tags ?? "[]",
            confidence_score: params.confidenceScore ?? 0.5
          };
          this.tables.list_items.set(String(row.id), row);
          return { changes: 1 };
        },
        get: unsupported("get", "INSERT INTO list_items"),
        all: unsupported("all", "INSERT INTO list_items")
      };
    }

    if (normalized === "SELECT * FROM LIST_ITEMS WHERE ID = ?") {
      return {
        run: unsupported("run", "SELECT * FROM list_items WHERE id = ?"),
        get: (id?: unknown) => {
          if (typeof id !== "string") return undefined;
          return this.tables.list_items.get(id);
        },
        all: unsupported("all", "SELECT * FROM list_items WHERE id = ?")
      };
    }

    if (normalized === "SELECT * FROM LIST_ITEMS WHERE LIST_TYPE = ? ORDER BY CREATED_AT DESC") {
      return {
        run: unsupported("run", "SELECT * FROM list_items WHERE list_type = ?"),
        get: unsupported("get", "SELECT * FROM list_items WHERE list_type = ?"),
        all: (listType?: unknown) => {
          const filtered = Array.from(this.tables.list_items.values()).filter(
            (row) => row.list_type === listType
          );
          return filtered.sort((a, b) => compareDesc(a.created_at, b.created_at));
        }
      };
    }

    if (normalized === "SELECT * FROM LIST_ITEMS ORDER BY CREATED_AT DESC") {
      return {
        run: unsupported("run", "SELECT * FROM list_items ORDER BY created_at DESC"),
        get: unsupported("get", "SELECT * FROM list_items ORDER BY created_at DESC"),
        all: () => {
          return Array.from(this.tables.list_items.values()).sort((a, b) =>
            compareDesc(a.created_at, b.created_at)
          );
        }
      };
    }

    if (normalized === "DELETE FROM LIST_ITEMS WHERE ID = ?") {
      return {
        run: (id?: unknown) => {
          if (typeof id !== "string") return { changes: 0 };
          const existed = this.tables.list_items.delete(id);
          return { changes: existed ? 1 : 0 };
        },
        get: unsupported("get", "DELETE FROM list_items WHERE id = ?"),
        all: unsupported("all", "DELETE FROM list_items WHERE id = ?")
      };
    }

    if (normalized.startsWith("INSERT INTO FOCUS_CARDS")) {
      return {
        run: (bindings?: Record<string, any>) => {
          const params = bindings ?? {};
          const row = {
            id: params.id,
            date: params.date,
            items: params.items ?? "[]",
            theme: params.theme ?? "",
            energy_budget: params.energyBudget ?? "medium",
            success_metric: params.successMetric ?? "",
            reflection: params.reflection ?? "",
            used_ai_suggestions: params.usedAiSuggestions ?? 0
          };
          this.tables.focus_cards.set(String(row.date), row);
          return { changes: 1 };
        },
        get: unsupported("get", "INSERT INTO focus_cards"),
        all: unsupported("all", "INSERT INTO focus_cards")
      };
    }

    if (normalized === "SELECT * FROM FOCUS_CARDS WHERE DATE = ?") {
      return {
        run: unsupported("run", "SELECT * FROM focus_cards WHERE date = ?"),
        get: (date?: unknown) => {
          if (typeof date !== "string") return undefined;
          return this.tables.focus_cards.get(date);
        },
        all: unsupported("all", "SELECT * FROM focus_cards WHERE date = ?")
      };
    }

    if (normalized === "SELECT * FROM FOCUS_CARDS ORDER BY DATE DESC LIMIT ?") {
      return {
        run: unsupported("run", "SELECT * FROM focus_cards ORDER BY date DESC LIMIT ?"),
        get: unsupported("get", "SELECT * FROM focus_cards ORDER BY date DESC LIMIT ?"),
        all: (limit?: unknown) => {
          const max = typeof limit === "number" ? limit : 30;
          return Array.from(this.tables.focus_cards.values())
            .sort((a, b) => compareDesc(a.date, b.date))
            .slice(0, max);
        }
      };
    }

    if (normalized.startsWith("INSERT INTO ANTI_TODO_ENTRIES")) {
      return {
        run: (bindings?: Record<string, any>) => {
          const params = bindings ?? {};
          const row = {
            id: params.id,
            title: params.title,
            completed_at: params.completedAt
          };
          this.tables.anti_todo_entries.set(String(row.id), row);
          return { changes: 1 };
        },
        get: unsupported("get", "INSERT INTO anti_todo_entries"),
        all: unsupported("all", "INSERT INTO anti_todo_entries")
      };
    }

    if (
      normalized ===
      "SELECT * FROM ANTI_TODO_ENTRIES WHERE COMPLETED_AT BETWEEN ? AND ? ORDER BY COMPLETED_AT DESC"
    ) {
      return {
        run: unsupported("run", "SELECT * FROM anti_todo_entries BETWEEN"),
        get: unsupported("get", "SELECT * FROM anti_todo_entries BETWEEN"),
        all: (start?: unknown, end?: unknown) => {
          if (typeof start !== "string" || typeof end !== "string") return [];
          return Array.from(this.tables.anti_todo_entries.values())
            .filter(
              (row) =>
                compareDates(row.completed_at, start) >= 0 &&
                compareDates(row.completed_at, end) <= 0
            )
            .sort((a, b) => compareDesc(a.completed_at, b.completed_at));
        }
      };
    }

    if (normalized.startsWith("INSERT INTO USER_PREFERENCES")) {
      return {
        run: (bindings?: Record<string, any>) => {
          const params = bindings ?? {};
          const row = {
            user_id: params.userId,
            planning_time: params.planningTime,
            planning_hour: params.planningHour ?? null,
            notifications_enabled: params.notificationsEnabled ?? 1,
            timezone: params.timezone,
            onboarding_completed_at: params.onboardingCompletedAt ?? null,
            onboarding_version: params.onboardingVersion ?? "3.0"
          };
          this.tables.user_preferences.set(String(row.user_id), row);
          return { changes: 1 };
        },
        get: unsupported("get", "INSERT INTO user_preferences"),
        all: unsupported("all", "INSERT INTO user_preferences")
      };
    }

    if (normalized === "SELECT USER_ID AS USERID, PLANNING_TIME AS PLANNINGTIME, PLANNING_HOUR AS PLANNINGHOUR, NOTIFICATIONS_ENABLED AS NOTIFICATIONSENABLED, TIMEZONE, ONBOARDING_COMPLETED_AT AS ONBOARDINGCOMPLETEDAT, ONBOARDING_VERSION AS ONBOARDINGVERSION FROM USER_PREFERENCES WHERE USER_ID = ?") {
      return {
        run: unsupported("run", "SELECT ... FROM user_preferences WHERE user_id = ?"),
        get: (userId?: unknown) => {
          if (typeof userId !== "string") return undefined;
          const row = this.tables.user_preferences.get(userId);
          if (!row) return undefined;
          return {
            userId: row.user_id,
            planningTime: row.planning_time,
            planningHour: row.planning_hour,
            notificationsEnabled: row.notifications_enabled,
            timezone: row.timezone,
            onboardingCompletedAt: row.onboarding_completed_at,
            onboardingVersion: row.onboarding_version
          };
        },
        all: unsupported("all", "SELECT ... FROM user_preferences WHERE user_id = ?")
      };
    }

    if (normalized.startsWith("ALTER TABLE")) {
      return noopStatement();
    }

    if (normalized.startsWith("PRAGMA TABLE_INFO(")) {
      const table = normalized.match(/PRAGMA TABLE_INFO\((.+)\)/)?.[1]?.toLowerCase() as
        | TableName
        | undefined;
      const columns = getTableColumns(table);
      return {
        run: unsupported("run", "PRAGMA table_info"),
        get: unsupported("get", "PRAGMA table_info"),
        all: () => columns.map((name, index) => ({ cid: index, name }))
      };
    }

    throw new Error(`Unsupported SQL in in-memory database adapter: ${sql}`);
  }

  exec(sql: string) {
    const statements = sql
      .split(";")
      .map((segment) => segment.trim())
      .filter(Boolean);
    for (const statement of statements) {
      const normalized = normalize(statement);
      if (normalized.startsWith("DELETE FROM")) {
        const table = normalized.replace("DELETE FROM", "").trim().toLowerCase() as TableName;
        if (this.tables[table]) {
          this.tables[table].clear();
        }
      }
    }
  }

  pragma(_command: string) {
    // Intentionally no-op for in-memory adapter
  }
}

function noopStatement(): StatementResult {
  return {
    run: () => ({ changes: 0 }),
    get: () => undefined,
    all: () => []
  };
}

function unsupported(method: "run" | "get" | "all", sql: string) {
  return () => {
    throw new Error(`Unsupported ${method}() invocation for statement "${sql}" in in-memory DB`);
  };
}

function normalize(sql: string): string {
  return sql
    .replace(/\s+/g, " ")
    .trim()
    .toUpperCase();
}

function compareDesc(a: unknown, b: unknown): number {
  const valA = typeof a === "string" ? a : "";
  const valB = typeof b === "string" ? b : "";
  return valA < valB ? 1 : valA > valB ? -1 : 0;
}

function compareDates(value: unknown, reference: string): number {
  const tsValue = Date.parse(typeof value === "string" ? value : "");
  const tsRef = Date.parse(reference);
  if (Number.isNaN(tsValue) || Number.isNaN(tsRef)) return 0;
  return tsValue - tsRef;
}

function getTableColumns(table?: TableName): string[] {
  switch (table) {
    case "list_items":
      return [
        "id",
        "title",
        "list_type",
        "status",
        "notes",
        "due_at",
        "follow_up_at",
        "created_at",
        "completed_at",
        "tags",
        "confidence_score"
      ];
    case "focus_cards":
      return [
        "id",
        "date",
        "items",
        "theme",
        "energy_budget",
        "success_metric",
        "reflection",
        "used_ai_suggestions"
      ];
    case "anti_todo_entries":
      return ["id", "title", "completed_at"];
    case "user_preferences":
      return [
        "user_id",
        "planning_time",
        "planning_hour",
        "notifications_enabled",
        "timezone",
        "onboarding_completed_at",
        "onboarding_version"
      ];
    default:
      return [];
  }
}
