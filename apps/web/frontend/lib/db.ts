import { openDB, DBSchema, IDBPDatabase } from 'idb';
import type { ListItem, DailyFocusCard, AntiTodoEntry } from './api-client';

// ============================================================================
// Database Schema
// ============================================================================

interface AndreDB extends DBSchema {
  listItems: {
    key: string;
    value: ListItem;
    indexes: {
      'by-list-type': string;
      'by-status': string;
      'by-created': string;
    };
  };
  focusCards: {
    key: string;
    value: DailyFocusCard;
    indexes: {
      'by-date': string;
    };
  };
  antiTodoEntries: {
    key: string;
    value: AntiTodoEntry;
    indexes: {
      'by-completed': string;
    };
  };
  syncQueue: {
    key: string;
    value: {
      id: string;
      operation: 'create' | 'update' | 'delete';
      entity: 'listItem' | 'focusCard' | 'antiTodoEntry';
      data: unknown;
      timestamp: number;
      retries: number;
    };
    indexes: {
      'by-timestamp': number;
    };
  };
}

// ============================================================================
// Database Manager
// ============================================================================

class DatabaseManager {
  private db: IDBPDatabase<AndreDB> | null = null;
  private dbName = 'andre-db';
  private version = 1;

  async init() {
    if (this.db) return this.db;

    this.db = await openDB<AndreDB>(this.dbName, this.version, {
      upgrade(db) {
        // List Items store
        if (!db.objectStoreNames.contains('listItems')) {
          const listItemsStore = db.createObjectStore('listItems', {
            keyPath: 'id',
          });
          listItemsStore.createIndex('by-list-type', 'listType');
          listItemsStore.createIndex('by-status', 'status');
          listItemsStore.createIndex('by-created', 'createdAt');
        }

        // Focus Cards store
        if (!db.objectStoreNames.contains('focusCards')) {
          const focusCardsStore = db.createObjectStore('focusCards', {
            keyPath: 'id',
          });
          focusCardsStore.createIndex('by-date', 'date');
        }

        // Anti-Todo Entries store
        if (!db.objectStoreNames.contains('antiTodoEntries')) {
          const antiTodoStore = db.createObjectStore('antiTodoEntries', {
            keyPath: 'id',
          });
          antiTodoStore.createIndex('by-completed', 'completedAt');
        }

        // Sync Queue store
        if (!db.objectStoreNames.contains('syncQueue')) {
          const syncQueueStore = db.createObjectStore('syncQueue', {
            keyPath: 'id',
          });
          syncQueueStore.createIndex('by-timestamp', 'timestamp');
        }
      },
    });

    return this.db;
  }

  // ============================================================================
  // List Items
  // ============================================================================

  async saveListItem(item: ListItem): Promise<void> {
    const db = await this.init();
    await db.put('listItems', item);
  }

  async saveListItems(items: ListItem[]): Promise<void> {
    const db = await this.init();
    const tx = db.transaction('listItems', 'readwrite');
    await Promise.all(items.map((item) => tx.store.put(item)));
    await tx.done;
  }

  async getListItem(id: string): Promise<ListItem | undefined> {
    const db = await this.init();
    return db.get('listItems', id);
  }

  async getListItems(): Promise<ListItem[]> {
    const db = await this.init();
    return db.getAll('listItems');
  }

  async getListItemsByType(listType: string): Promise<ListItem[]> {
    const db = await this.init();
    return db.getAllFromIndex('listItems', 'by-list-type', listType);
  }

  async deleteListItem(id: string): Promise<void> {
    const db = await this.init();
    await db.delete('listItems', id);
  }

  async clearListItems(): Promise<void> {
    const db = await this.init();
    await db.clear('listItems');
  }

  // ============================================================================
  // Focus Cards
  // ============================================================================

  async saveFocusCard(card: DailyFocusCard): Promise<void> {
    const db = await this.init();
    await db.put('focusCards', card);
  }

  async getFocusCard(id: string): Promise<DailyFocusCard | undefined> {
    const db = await this.init();
    return db.get('focusCards', id);
  }

  async getFocusCardByDate(date: string): Promise<DailyFocusCard | undefined> {
    const db = await this.init();
    const cards = await db.getAllFromIndex('focusCards', 'by-date', date);
    return cards[0];
  }

  async getFocusCards(): Promise<DailyFocusCard[]> {
    const db = await this.init();
    return db.getAll('focusCards');
  }

  async deleteFocusCard(id: string): Promise<void> {
    const db = await this.init();
    await db.delete('focusCards', id);
  }

  // ============================================================================
  // Anti-Todo Entries
  // ============================================================================

  async saveAntiTodoEntry(entry: AntiTodoEntry): Promise<void> {
    const db = await this.init();
    await db.put('antiTodoEntries', entry);
  }

  async saveAntiTodoEntries(entries: AntiTodoEntry[]): Promise<void> {
    const db = await this.init();
    const tx = db.transaction('antiTodoEntries', 'readwrite');
    await Promise.all(entries.map((entry) => tx.store.put(entry)));
    await tx.done;
  }

  async getAntiTodoEntry(id: string): Promise<AntiTodoEntry | undefined> {
    const db = await this.init();
    return db.get('antiTodoEntries', id);
  }

  async getAntiTodoEntries(): Promise<AntiTodoEntry[]> {
    const db = await this.init();
    return db.getAll('antiTodoEntries');
  }

  async getAntiTodoEntriesByDate(date: string): Promise<AntiTodoEntry[]> {
    const db = await this.init();
    const allEntries = await db.getAll('antiTodoEntries');
    return allEntries.filter((entry) => entry.completedAt.startsWith(date));
  }

  async deleteAntiTodoEntry(id: string): Promise<void> {
    const db = await this.init();
    await db.delete('antiTodoEntries', id);
  }

  // ============================================================================
  // Sync Queue
  // ============================================================================

  async addToSyncQueue(operation: {
    id: string;
    operation: 'create' | 'update' | 'delete';
    entity: 'listItem' | 'focusCard' | 'antiTodoEntry';
    data: unknown;
    timestamp: number;
    retries: number;
  }): Promise<void> {
    const db = await this.init();
    await db.put('syncQueue', operation);
  }

  async getSyncQueue(): Promise<
    Array<{
      id: string;
      operation: 'create' | 'update' | 'delete';
      entity: 'listItem' | 'focusCard' | 'antiTodoEntry';
      data: unknown;
      timestamp: number;
      retries: number;
    }>
  > {
    const db = await this.init();
    return db.getAll('syncQueue');
  }

  async removeSyncQueueItem(id: string): Promise<void> {
    const db = await this.init();
    await db.delete('syncQueue', id);
  }

  async clearSyncQueue(): Promise<void> {
    const db = await this.init();
    await db.clear('syncQueue');
  }

  // ============================================================================
  // Utilities
  // ============================================================================

  async clearAll(): Promise<void> {
    const db = await this.init();
    await db.clear('listItems');
    await db.clear('focusCards');
    await db.clear('antiTodoEntries');
    await db.clear('syncQueue');
  }
}

export const db = new DatabaseManager();
