import Database from "better-sqlite3";
import path from "node:path";
import fs from "node:fs";

const DEFAULT_DB_PATH = path.join(process.cwd(), "andre.db");

export interface SQLiteConfig {
  filename?: string;
  memory?: boolean;
}

let db: Database.Database | null = null;

export function connect(config: SQLiteConfig = {}): Database.Database {
  if (db) return db;

  const filename = config.memory ? ":memory:" : config.filename ?? DEFAULT_DB_PATH;
  if (filename !== ":memory:") {
    const dir = path.dirname(filename);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  }

  db = new Database(filename);
  db.pragma("journal_mode = WAL");
  initialiseSchema(db);
  return db;
}

function initialiseSchema(database: Database.Database) {
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
        reflection TEXT
      )
    `)
    .run();

  database
    .prepare(`
      CREATE TABLE IF NOT EXISTS anti_todo_entries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    `)
    .run();
}

export function resetDatabase() {
  if (!db) return;
  db.exec("DELETE FROM list_items");
  db.exec("DELETE FROM focus_cards");
  db.exec("DELETE FROM anti_todo_entries");
}

export function getDbInstance(): Database.Database {
  if (!db) {
    throw new Error("SQLite not connected. Call connect() first.");
  }
  return db;
}
