# Andre Web Application - Development Roadmap

## Project Overview

Build a production-ready web application for Andre's three-list productivity system, maintaining complete feature parity with the iOS app while optimizing for desktop workflows. Deploy to Vercel with offline-first architecture.

**Target**: Desktop and mobile web users
**Timeline**: 5 weeks
**Stack**: Next.js 14 + TypeScript + Tailwind + Zustand
**Deployment**: Vercel (with preview deployments)

---

## Design System Reference

### Colors (Match iOS exactly)
```css
/* Primary Brand */
--brand-black: #000000;
--brand-cyan: #00FFFF;
--brand-white: #FFFFFF;

/* Extended Palette */
--brand-dark-gray: #1A1A1A;
--brand-light-gray: #F5F5F5;
--brand-bright-green: #00FF00;
--brand-electric-blue: #0066FF;

/* Semantic (Dark Theme Default) */
--background-primary: #000000;
--background-secondary: #1A1A1A;
--background-tertiary: #2A2A2A;

--text-primary: #FFFFFF;
--text-secondary: #CCCCCC;
--text-tertiary: #999999;

--accent-primary: #00FFFF;
--accent-secondary: #0066FF;

--status-success: #00FF00;
--status-warning: #FFA500;
--status-error: #FF3B30;
--status-info: #00FFFF;

/* List Type Colors */
--list-todo: #00FFFF;     /* Cyan */
--list-watch: #FFD60A;    /* Yellow */
--list-later: #BF5AF2;    /* Purple */
--list-anti-todo: #00FF00; /* Green */
```

### Typography
```css
/* Display Styles */
font-display-xl: 48px semibold
font-display-large: 40px semibold
font-display-medium: 34px semibold
font-display-small: 28px semibold

/* Title Styles */
font-title-large: 24px bold
font-title-medium: 20px semibold
font-title-small: 18px semibold

/* Body Styles */
font-body-large: 17px regular
font-body-medium: 15px regular (default)
font-body-small: 13px regular

/* Label Styles */
font-label-large: 14px medium
font-label-medium: 12px medium
font-label-small: 11px medium
```

### Spacing (8px Base Grid)
```css
--spacing-xxs: 4px;
--spacing-xs: 8px;
--spacing-sm: 12px;
--spacing-md: 16px;
--spacing-lg: 24px;
--spacing-xl: 32px;
--spacing-xxl: 48px;
--spacing-xxxl: 64px;
--spacing-xxxxl: 96px;

/* Semantic */
--screen-padding: 16px;
--card-padding: 24px;
--section-spacing: 32px;
```

### Corner Radius
```css
--radius-small: 4px;
--radius-medium: 8px;
--radius-large: 12px;
--radius-xl: 16px;
--radius-pill: 999px;
```

---

## API Endpoints Reference

### Lists API (`/v1/lists`)
```typescript
GET    /v1/lists              // Get all lists
POST   /v1/lists              // Create new item
GET    /v1/lists/:id          // Get single item
PUT    /v1/lists/:id          // Update item
DELETE /v1/lists/:id          // Delete item
GET    /v1/lists/board        // Get organized board view
```

### Focus Cards API (`/v1/focus`)
```typescript
GET    /v1/focus/:date        // Get focus card for date
POST   /v1/focus              // Create focus card
PUT    /v1/focus/:id          // Update focus card
POST   /v1/focus/generate     // AI-generate focus card
GET    /v1/focus/tomorrow     // Get tomorrow's card
```

### Suggestions API (`/v1/suggestions`)
```typescript
GET    /v1/suggestions/structured-procrastination?limit=5
```

### Anti-Todo API (`/v1/anti-todo`)
```typescript
GET    /v1/anti-todo/:date    // Get entries for date
POST   /v1/anti-todo          // Log new win
GET    /v1/anti-todo/summary  // Get daily summary
```

### Domain Models

**ListItem**:
```typescript
interface ListItem {
  id: string;
  title: string;
  listType: 'todo' | 'watch' | 'later' | 'antiTodo';
  status: 'planned' | 'in_progress' | 'completed' | 'archived';
  notes?: string;
  dueAt?: Date;
  followUpAt?: Date;
  createdAt: Date;
  completedAt?: Date;
  tags: string[];
}
```

**DailyFocusCard**:
```typescript
interface DailyFocusCard {
  id: string;
  date: Date;
  items: ListItem[];
  meta: {
    theme: string;
    energyBudget: 'low' | 'medium' | 'high';
    successMetric: string;
  };
  reflection?: string;
}
```

**Suggestion**:
```typescript
interface Suggestion {
  id: string;
  title: string;
  description: string;
  listType: ListItem['listType'];
  score: number; // 0.0 to 1.0
  source: 'later' | 'watch' | 'momentum';
}
```

**AntiTodoEntry**:
```typescript
interface AntiTodoEntry {
  id: string;
  title: string;
  completedAt: Date;
}
```

---

## Phase 1: Foundation & Setup (Week 1)

### Agent: `react-nextjs-expert`

**Task 1.1**: Initialize Next.js Project
```bash
cd apps/web/frontend
pnpm create next-app@latest . --typescript --tailwind --app --no-src-dir
```

**Configuration**:
- TypeScript: strict mode
- ESLint: enabled
- App Router: enabled
- No `/src` directory (use `/app` directly)

**Files to create**:
- `package.json` with dependencies:
  ```json
  {
    "dependencies": {
      "next": "^14.1.0",
      "react": "^18.2.0",
      "react-dom": "^18.2.0",
      "zustand": "^4.5.0",
      "@tanstack/react-query": "^5.20.0",
      "framer-motion": "^11.0.0",
      "idb": "^8.0.0",
      "zod": "^3.22.0",
      "react-hook-form": "^7.50.0",
      "@hookform/resolvers": "^3.3.0",
      "date-fns": "^3.3.0"
    },
    "devDependencies": {
      "@types/node": "^20",
      "@types/react": "^18",
      "@types/react-dom": "^18",
      "typescript": "^5",
      "tailwindcss": "^3.4.0",
      "autoprefixer": "^10",
      "postcss": "^8",
      "eslint": "^8",
      "eslint-config-next": "14.1.0"
    }
  }
  ```

**Task 1.2**: Configure Tailwind with Design Tokens

**Agent**: `tailwind-frontend-expert`

Create `tailwind.config.ts`:
```typescript
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          black: '#000000',
          cyan: '#00FFFF',
          white: '#FFFFFF',
          'dark-gray': '#1A1A1A',
          'light-gray': '#F5F5F5',
          'bright-green': '#00FF00',
          'electric-blue': '#0066FF',
        },
        background: {
          primary: '#000000',
          secondary: '#1A1A1A',
          tertiary: '#2A2A2A',
        },
        text: {
          primary: '#FFFFFF',
          secondary: '#CCCCCC',
          tertiary: '#999999',
        },
        accent: {
          primary: '#00FFFF',
          secondary: '#0066FF',
        },
        status: {
          success: '#00FF00',
          warning: '#FFA500',
          error: '#FF3B30',
          info: '#00FFFF',
        },
        list: {
          todo: '#00FFFF',
          watch: '#FFD60A',
          later: '#BF5AF2',
          antiTodo: '#00FF00',
        },
      },
      spacing: {
        'xxs': '4px',
        'xs': '8px',
        'sm': '12px',
        'md': '16px',
        'lg': '24px',
        'xl': '32px',
        'xxl': '48px',
        'xxxl': '64px',
        'xxxxl': '96px',
      },
      fontSize: {
        'display-xl': ['48px', { lineHeight: '1.2', fontWeight: '600' }],
        'display-lg': ['40px', { lineHeight: '1.2', fontWeight: '600' }],
        'display-md': ['34px', { lineHeight: '1.2', fontWeight: '600' }],
        'display-sm': ['28px', { lineHeight: '1.3', fontWeight: '600' }],
        'title-lg': ['24px', { lineHeight: '1.3', fontWeight: '700' }],
        'title-md': ['20px', { lineHeight: '1.4', fontWeight: '600' }],
        'title-sm': ['18px', { lineHeight: '1.4', fontWeight: '600' }],
        'body-lg': ['17px', { lineHeight: '1.5', fontWeight: '400' }],
        'body-md': ['15px', { lineHeight: '1.5', fontWeight: '400' }],
        'body-sm': ['13px', { lineHeight: '1.5', fontWeight: '400' }],
        'label-lg': ['14px', { lineHeight: '1.4', fontWeight: '500' }],
        'label-md': ['12px', { lineHeight: '1.4', fontWeight: '500' }],
        'label-sm': ['11px', { lineHeight: '1.4', fontWeight: '500' }],
      },
      borderRadius: {
        'small': '4px',
        'medium': '8px',
        'large': '12px',
        'xl': '16px',
        'pill': '999px',
      },
    },
  },
  plugins: [],
};

export default config;
```

**Task 1.3**: Vercel Deployment Configuration

**Agent**: `backend-developer`

Create `vercel.json`:
```json
{
  "buildCommand": "pnpm build",
  "outputDirectory": ".next",
  "devCommand": "pnpm dev",
  "installCommand": "pnpm install",
  "framework": "nextjs",
  "regions": ["iad1"],
  "env": {
    "NEXT_PUBLIC_API_URL": "@api-url-production"
  },
  "preview": {
    "env": {
      "NEXT_PUBLIC_API_URL": "@api-url-preview"
    }
  }
}
```

Create `.env.local`:
```bash
NEXT_PUBLIC_API_URL=http://localhost:3000
```

**Task 1.4**: API Client Setup

**Agent**: `backend-developer`

Create `lib/api-client.ts`:
```typescript
import { z } from 'zod';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

// Zod schemas for validation
export const ListItemSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  listType: z.enum(['todo', 'watch', 'later', 'antiTodo']),
  status: z.enum(['planned', 'in_progress', 'completed', 'archived']),
  notes: z.string().optional(),
  dueAt: z.string().datetime().optional(),
  followUpAt: z.string().datetime().optional(),
  createdAt: z.string().datetime(),
  completedAt: z.string().datetime().optional(),
  tags: z.array(z.string()),
});

export const DailyFocusCardSchema = z.object({
  id: z.string().uuid(),
  date: z.string(),
  items: z.array(ListItemSchema),
  meta: z.object({
    theme: z.string(),
    energyBudget: z.enum(['low', 'medium', 'high']),
    successMetric: z.string(),
  }),
  reflection: z.string().optional(),
});

export const SuggestionSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  listType: z.enum(['todo', 'watch', 'later', 'antiTodo']),
  score: z.number().min(0).max(1),
  source: z.enum(['later', 'watch', 'momentum']),
});

export const AntiTodoEntrySchema = z.object({
  id: z.string().uuid(),
  title: z.string(),
  completedAt: z.string().datetime(),
});

export type ListItem = z.infer<typeof ListItemSchema>;
export type DailyFocusCard = z.infer<typeof DailyFocusCardSchema>;
export type Suggestion = z.infer<typeof SuggestionSchema>;
export type AntiTodoEntry = z.infer<typeof AntiTodoEntrySchema>;

// API Client
class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }

    return response.json();
  }

  // Lists API
  async getLists(): Promise<ListItem[]> {
    const data = await this.request<unknown>('/v1/lists');
    return z.array(ListItemSchema).parse(data);
  }

  async getListBoard(): Promise<{ todo: ListItem[]; watch: ListItem[]; later: ListItem[] }> {
    return this.request('/v1/lists/board');
  }

  async createListItem(item: Omit<ListItem, 'id' | 'createdAt'>): Promise<ListItem> {
    const data = await this.request<unknown>('/v1/lists', {
      method: 'POST',
      body: JSON.stringify(item),
    });
    return ListItemSchema.parse(data);
  }

  async updateListItem(id: string, updates: Partial<ListItem>): Promise<ListItem> {
    const data = await this.request<unknown>(`/v1/lists/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    });
    return ListItemSchema.parse(data);
  }

  async deleteListItem(id: string): Promise<void> {
    await this.request(`/v1/lists/${id}`, { method: 'DELETE' });
  }

  // Focus Cards API
  async getFocusCard(date: string): Promise<DailyFocusCard> {
    const data = await this.request<unknown>(`/v1/focus/${date}`);
    return DailyFocusCardSchema.parse(data);
  }

  async createFocusCard(card: Omit<DailyFocusCard, 'id'>): Promise<DailyFocusCard> {
    const data = await this.request<unknown>('/v1/focus', {
      method: 'POST',
      body: JSON.stringify(card),
    });
    return DailyFocusCardSchema.parse(data);
  }

  async generateFocusCard(date: string): Promise<DailyFocusCard> {
    const data = await this.request<unknown>('/v1/focus/generate', {
      method: 'POST',
      body: JSON.stringify({ date }),
    });
    return DailyFocusCardSchema.parse(data);
  }

  // Suggestions API
  async getSuggestions(limit: number = 5): Promise<Suggestion[]> {
    const data = await this.request<unknown>(
      `/v1/suggestions/structured-procrastination?limit=${limit}`
    );
    return z.array(SuggestionSchema).parse(data);
  }

  // Anti-Todo API
  async getAntiTodoEntries(date: string): Promise<AntiTodoEntry[]> {
    const data = await this.request<unknown>(`/v1/anti-todo/${date}`);
    return z.array(AntiTodoEntrySchema).parse(data);
  }

  async logAntiTodoEntry(entry: Omit<AntiTodoEntry, 'id' | 'completedAt'>): Promise<AntiTodoEntry> {
    const data = await this.request<unknown>('/v1/anti-todo', {
      method: 'POST',
      body: JSON.stringify(entry),
    });
    return AntiTodoEntrySchema.parse(data);
  }
}

export const apiClient = new ApiClient();
```

**Task 1.5**: State Management Setup

**Agent**: `react-state-manager`

Create `lib/store.ts`:
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { ListItem, DailyFocusCard, Suggestion, AntiTodoEntry } from './api-client';

interface AppState {
  // Lists
  lists: {
    todo: ListItem[];
    watch: ListItem[];
    later: ListItem[];
  };
  setLists: (lists: AppState['lists']) => void;

  // Focus Card
  currentFocusCard: DailyFocusCard | null;
  setCurrentFocusCard: (card: DailyFocusCard | null) => void;

  // Suggestions
  suggestions: Suggestion[];
  setSuggestions: (suggestions: Suggestion[]) => void;

  // Anti-Todo
  antiTodoEntries: AntiTodoEntry[];
  setAntiTodoEntries: (entries: AntiTodoEntry[]) => void;

  // UI State
  isOnboardingComplete: boolean;
  setOnboardingComplete: (complete: boolean) => void;

  selectedListType: 'todo' | 'watch' | 'later' | null;
  setSelectedListType: (type: AppState['selectedListType']) => void;

  isPlanningMode: boolean;
  setPlanningMode: (mode: boolean) => void;

  selectedItemsForPlanning: Set<string>;
  toggleItemSelection: (itemId: string) => void;
  clearSelection: () => void;
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial state
      lists: { todo: [], watch: [], later: [] },
      currentFocusCard: null,
      suggestions: [],
      antiTodoEntries: [],
      isOnboardingComplete: false,
      selectedListType: null,
      isPlanningMode: false,
      selectedItemsForPlanning: new Set(),

      // Actions
      setLists: (lists) => set({ lists }),
      setCurrentFocusCard: (card) => set({ currentFocusCard: card }),
      setSuggestions: (suggestions) => set({ suggestions }),
      setAntiTodoEntries: (entries) => set({ antiTodoEntries: entries }),
      setOnboardingComplete: (complete) => set({ isOnboardingComplete: complete }),
      setSelectedListType: (type) => set({ selectedListType: type }),
      setPlanningMode: (mode) => set({ isPlanningMode: mode }),

      toggleItemSelection: (itemId) => {
        const selected = new Set(get().selectedItemsForPlanning);
        if (selected.has(itemId)) {
          selected.delete(itemId);
        } else {
          selected.add(itemId);
        }
        set({ selectedItemsForPlanning: selected });
      },

      clearSelection: () => set({ selectedItemsForPlanning: new Set() }),
    }),
    {
      name: 'andre-storage',
      partialize: (state) => ({
        isOnboardingComplete: state.isOnboardingComplete,
      }),
    }
  )
);
```

**Task 1.6**: IndexedDB Offline Storage

**Agent**: `backend-developer`

Create `lib/db.ts`:
```typescript
import { openDB, DBSchema, IDBPDatabase } from 'idb';
import type { ListItem, DailyFocusCard, AntiTodoEntry } from './api-client';

interface AndreDB extends DBSchema {
  listItems: {
    key: string;
    value: ListItem;
    indexes: {
      'by-list-type': string;
      'by-status': string;
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
      'by-date': string;
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
    };
  };
}

class DatabaseManager {
  private db: IDBPDatabase<AndreDB> | null = null;

  async init() {
    this.db = await openDB<AndreDB>('andre-db', 1, {
      upgrade(db) {
        // List Items store
        const listItemsStore = db.createObjectStore('listItems', { keyPath: 'id' });
        listItemsStore.createIndex('by-list-type', 'listType');
        listItemsStore.createIndex('by-status', 'status');

        // Focus Cards store
        const focusCardsStore = db.createObjectStore('focusCards', { keyPath: 'id' });
        focusCardsStore.createIndex('by-date', 'date');

        // Anti-Todo Entries store
        const antiTodoStore = db.createObjectStore('antiTodoEntries', { keyPath: 'id' });
        antiTodoStore.createIndex('by-date', 'completedAt');

        // Sync Queue store
        db.createObjectStore('syncQueue', { keyPath: 'id' });
      },
    });
  }

  // List Items
  async saveListItem(item: ListItem) {
    if (!this.db) await this.init();
    await this.db!.put('listItems', item);
  }

  async getListItems(): Promise<ListItem[]> {
    if (!this.db) await this.init();
    return this.db!.getAll('listItems');
  }

  async getListItemsByType(listType: string): Promise<ListItem[]> {
    if (!this.db) await this.init();
    return this.db!.getAllFromIndex('listItems', 'by-list-type', listType);
  }

  async deleteListItem(id: string) {
    if (!this.db) await this.init();
    await this.db!.delete('listItems', id);
  }

  // Focus Cards
  async saveFocusCard(card: DailyFocusCard) {
    if (!this.db) await this.init();
    await this.db!.put('focusCards', card);
  }

  async getFocusCardByDate(date: string): Promise<DailyFocusCard | undefined> {
    if (!this.db) await this.init();
    return this.db!.getFromIndex('focusCards', 'by-date', date);
  }

  async getFocusCards(): Promise<DailyFocusCard[]> {
    if (!this.db) await this.init();
    return this.db!.getAll('focusCards');
  }

  // Anti-Todo Entries
  async saveAntiTodoEntry(entry: AntiTodoEntry) {
    if (!this.db) await this.init();
    await this.db!.put('antiTodoEntries', entry);
  }

  async getAntiTodoEntriesByDate(date: string): Promise<AntiTodoEntry[]> {
    if (!this.db) await this.init();
    const allEntries = await this.db!.getAll('antiTodoEntries');
    return allEntries.filter(entry => entry.completedAt.startsWith(date));
  }

  // Sync Queue
  async addToSyncQueue(operation: any) {
    if (!this.db) await this.init();
    await this.db!.put('syncQueue', operation);
  }

  async getSyncQueue() {
    if (!this.db) await this.init();
    return this.db!.getAll('syncQueue');
  }

  async clearSyncQueue() {
    if (!this.db) await this.init();
    await this.db!.clear('syncQueue');
  }
}

export const db = new DatabaseManager();
```

**Task 1.7**: Root Layout

**Agent**: `react-nextjs-expert`

Create `app/layout.tsx`:
```typescript
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from './providers';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Andre - Three-List Productivity',
  description: 'Master focus. Build momentum. Track wins.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.className} bg-background-primary text-text-primary`}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

Create `app/providers.tsx`:
```typescript
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState } from 'react';

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minute
        refetchOnWindowFocus: false,
      },
    },
  }));

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}
```

Create `app/globals.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 255, 255, 255;
  --background-start-rgb: 0, 0, 0;
  --background-end-rgb: 0, 0, 0;
}

body {
  color: rgb(var(--foreground-rgb));
  background: linear-gradient(
      to bottom,
      transparent,
      rgb(var(--background-end-rgb))
    )
    rgb(var(--background-start-rgb));
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}
```

---

## Phase 2: Component Library (Week 1-2)

### Agent: `ui-forge-prime`

**Task 2.1**: Base Button Component

Create `components/ui/Button.tsx`:
```typescript
'use client';

import { ButtonHTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-medium font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-primary disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-accent-primary text-brand-black hover:bg-accent-primary/90',
        secondary: 'bg-background-secondary text-text-primary hover:bg-background-tertiary',
        ghost: 'hover:bg-background-secondary',
        borderless: 'text-accent-primary hover:text-accent-primary/80',
      },
      size: {
        small: 'h-8 px-3 text-label-md',
        medium: 'h-11 px-4 text-body-md',
        large: 'h-14 px-6 text-body-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'medium',
    },
  }
);

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={buttonVariants({ variant, size, className })}
        ref={ref}
        {...props}
      />
    );
  }
);

Button.displayName = 'Button';

export { Button, buttonVariants };
```

**Task 2.2**: Card Component

Create `components/ui/Card.tsx`:
```typescript
'use client';

import { HTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const cardVariants = cva(
  'rounded-large transition-all',
  {
    variants: {
      style: {
        default: 'bg-background-secondary border border-background-tertiary',
        glass: 'bg-background-secondary/60 backdrop-blur-md border border-background-tertiary/40',
        accent: 'bg-accent-primary/10 border border-accent-primary/30',
        elevated: 'bg-background-secondary shadow-lg',
      },
      padding: {
        none: '',
        small: 'p-md',
        medium: 'p-lg',
        large: 'p-xl',
      },
    },
    defaultVariants: {
      style: 'default',
      padding: 'medium',
    },
  }
);

export interface CardProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof cardVariants> {}

const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, style, padding, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cardVariants({ style, padding, className })}
        {...props}
      />
    );
  }
);

Card.displayName = 'Card';

export { Card, cardVariants };
```

**Task 2.3**: TextField Component

Create `components/ui/TextField.tsx`:
```typescript
'use client';

import { InputHTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const inputVariants = cva(
  'w-full rounded-medium border bg-background-secondary px-md py-sm text-body-md text-text-primary placeholder:text-text-tertiary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-primary disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'border-background-tertiary',
        error: 'border-status-error focus-visible:ring-status-error',
        success: 'border-status-success focus-visible:ring-status-success',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface TextFieldProps
  extends InputHTMLAttributes<HTMLInputElement>,
    VariantProps<typeof inputVariants> {
  label?: string;
  error?: string;
  icon?: React.ReactNode;
}

const TextField = forwardRef<HTMLInputElement, TextFieldProps>(
  ({ className, variant, label, error, icon, ...props }, ref) => {
    return (
      <div className="space-y-xs">
        {label && (
          <label className="block text-label-md text-text-secondary">
            {label}
          </label>
        )}
        <div className="relative">
          {icon && (
            <div className="absolute left-md top-1/2 -translate-y-1/2 text-text-tertiary">
              {icon}
            </div>
          )}
          <input
            className={inputVariants({
              variant: error ? 'error' : variant,
              className: icon ? 'pl-10' : className,
            })}
            ref={ref}
            {...props}
          />
        </div>
        {error && (
          <p className="text-label-sm text-status-error">{error}</p>
        )}
      </div>
    );
  }
);

TextField.displayName = 'TextField';

export { TextField, inputVariants };
```

**Task 2.4**: Tag Component

Create `components/ui/Tag.tsx`:
```typescript
'use client';

import { HTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const tagVariants = cva(
  'inline-flex items-center gap-xxs rounded-pill px-sm py-xxs text-label-sm transition-colors',
  {
    variants: {
      variant: {
        default: 'bg-background-tertiary text-text-secondary',
        accent: 'bg-accent-primary/20 text-accent-primary',
        success: 'bg-status-success/20 text-status-success',
        warning: 'bg-status-warning/20 text-status-warning',
        error: 'bg-status-error/20 text-status-error',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface TagProps
  extends HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof tagVariants> {
  onRemove?: () => void;
}

const Tag = forwardRef<HTMLSpanElement, TagProps>(
  ({ className, variant, children, onRemove, ...props }, ref) => {
    return (
      <span
        ref={ref}
        className={tagVariants({ variant, className })}
        {...props}
      >
        {children}
        {onRemove && (
          <button
            type="button"
            onClick={onRemove}
            className="ml-xs hover:text-text-primary"
          >
            <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
              <path
                d="M9 3L3 9M3 3l6 6"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
              />
            </svg>
          </button>
        )}
      </span>
    );
  }
);

Tag.displayName = 'Tag';

export { Tag, tagVariants };
```

**Task 2.5**: Loading Indicator

Create `components/ui/LoadingIndicator.tsx`:
```typescript
'use client';

import { HTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const loadingVariants = cva('', {
  variants: {
    variant: {
      pulse: 'animate-pulse',
      spin: 'animate-spin',
    },
    size: {
      small: 'h-4 w-4',
      medium: 'h-6 w-6',
      large: 'h-8 w-8',
    },
  },
  defaultVariants: {
    variant: 'spin',
    size: 'medium',
  },
});

export interface LoadingIndicatorProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof loadingVariants> {
  message?: string;
}

export function LoadingIndicator({
  variant,
  size,
  message,
  className,
  ...props
}: LoadingIndicatorProps) {
  if (variant === 'pulse') {
    return (
      <div className="flex flex-col items-center gap-md" {...props}>
        <div className={loadingVariants({ variant, size, className })}>
          <div className="h-full w-full rounded-full bg-accent-primary" />
        </div>
        {message && (
          <p className="text-body-sm text-text-secondary">{message}</p>
        )}
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center gap-md" {...props}>
      <svg
        className={loadingVariants({ variant, size, className })}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle
          className="opacity-25"
          cx="12"
          cy="12"
          r="10"
          stroke="currentColor"
          strokeWidth="4"
        />
        <path
          className="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
      {message && (
        <p className="text-body-sm text-text-secondary">{message}</p>
      )}
    </div>
  );
}
```

**Additional Components to Create**:
- `Modal.tsx` - Dialog overlay
- `Sheet.tsx` - Bottom sheet for mobile
- `Checkbox.tsx` - Checkbox input
- `Select.tsx` - Dropdown select
- `TextArea.tsx` - Multi-line input
- `Toast.tsx` - Notification system
- `Badge.tsx` - Status badges
- `Avatar.tsx` - User avatar
- `Tabs.tsx` - Tab navigation
- `Progress.tsx` - Progress bar

---

## Phase 3: Core Features (Week 2-3)

### Lists Page (`/app/lists/page.tsx`)

**Agent**: `react-nextjs-expert`

**Requirements**:
1. Three-column layout (Todo, Watch, Later)
2. List type filter/selector
3. Item CRUD operations
4. Quick capture modal
5. Planning mode (select items for focus card)
6. Responsive: stacked columns on mobile (<768px)

**Components Needed**:
- `ListBoard` - Main board container
- `ListColumn` - Single list column
- `ListItem` - Individual item card
- `QuickCaptureModal` - Quick add item
- `ItemDetailModal` - Full item view/edit

**State Management**:
- Use React Query for server state
- Use Zustand for UI state (filter, planning mode)
- Optimistic updates for instant feedback

**Implementation Outline**:
```typescript
// app/lists/page.tsx
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { useAppStore } from '@/lib/store';
import { ListBoard } from '@/components/lists/ListBoard';
import { QuickCaptureModal } from '@/components/lists/QuickCaptureModal';

export default function ListsPage() {
  const queryClient = useQueryClient();
  const {
    isPlanningMode,
    setPlanningMode,
    selectedItemsForPlanning,
  } = useAppStore();

  const { data: board, isLoading } = useQuery({
    queryKey: ['lists', 'board'],
    queryFn: () => apiClient.getListBoard(),
  });

  const createItemMutation = useMutation({
    mutationFn: apiClient.createListItem,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lists'] });
    },
  });

  // Implementation continues...
}
```

---

### Focus Page (`/app/focus/page.tsx`)

**Agent**: `react-nextjs-expert`

**Requirements**:
1. Current day's focus card display
2. Planning wizard (3-step flow)
3. Tomorrow's card preview
4. Reflection input at end of day
5. Calendar view of past focus cards

**Components**:
- `FocusCard` - Card display
- `PlanningWizard` - 3-step modal
- `ReflectionModal` - End-of-day reflection
- `FocusCardCalendar` - Historical view

**Planning Wizard Steps**:
1. **Select Items** (1-5 items from lists)
2. **Set Context** (theme, energy budget)
3. **Define Success** (success metric)

---

### Switch Page (`/app/switch/page.tsx`)

**Agent**: `react-nextjs-expert`

**Requirements**:
1. Fetch suggestions from API
2. Display score (0-100%)
3. Show source (Later/Watch/Momentum)
4. List type badge with color
5. Refresh button

**Components**:
- `SuggestionCard` - Individual suggestion
- `SuggestionList` - Grid of suggestions

---

### Wins Page (`/app/wins/page.tsx`)

**Agent**: `react-nextjs-expert`

**Requirements**:
1. Timeline of today's accomplishments
2. Quick win entry button
3. Daily summary stats
4. Weekly/monthly rollup
5. Share/export functionality

**Components**:
- `WinTimeline` - Chronological list
- `WinEntry` - Single entry
- `AddWinModal` - Quick log
- `WinsSummary` - Stats card

---

## Phase 4: Onboarding Flow (Week 3)

### Agent: `ui-forge-prime`

**Requirements**:
- Translate iOS 12-screen onboarding
- Multi-step wizard with progress
- Interactive screens (items, focus card)
- LocalStorage persistence
- Celebration animation

**Screens**:
1. Welcome
2. Problem
3. Solution
4. Lists Tour
5. Focus Tour
6. Switch Tour
7. Wins Tour
8. Evening Ritual
9. Daily Execution
10. First Items (interactive)
11. First Focus Card (interactive)
12. Navigation Tour

**Implementation**:
- Use state machine for flow
- Save progress to LocalStorage
- Skip functionality
- Confetti animation on completion

---

## Phase 5: Sync & Offline (Week 4)

### Agent: `backend-developer`

**Requirements**:
1. Sync service with queue
2. IndexedDB caching
3. Optimistic updates
4. Background sync
5. Conflict resolution

**Implementation**:
```typescript
// lib/sync-service.ts
import { apiClient } from './api-client';
import { db } from './db';
import { useAppStore } from './store';

export class SyncService {
  private syncInProgress = false;

  async sync() {
    if (this.syncInProgress) return;
    this.syncInProgress = true;

    try {
      // Get sync queue
      const queue = await db.getSyncQueue();

      // Process queue
      for (const operation of queue) {
        await this.processOperation(operation);
      }

      // Clear queue
      await db.clearSyncQueue();

      // Full sync from server
      await this.pullFromServer();
    } finally {
      this.syncInProgress = false;
    }
  }

  private async processOperation(operation: any) {
    // Process each queued operation
    // Handle create, update, delete
  }

  private async pullFromServer() {
    // Fetch latest data from server
    // Update local cache
  }
}

export const syncService = new SyncService();
```

---

## Phase 6: Polish & Optimization (Week 4-5)

### Agents: `performance-optimizer`, `accessibility-auditor`, `ui-forge-prime`

**Performance Tasks**:
- Code splitting by route
- Lazy load modals/sheets
- Image optimization
- API response caching
- Virtual scrolling for long lists
- Debounced search/filters

**Accessibility Tasks**:
- Keyboard navigation (Tab, Enter, Esc, Arrows)
- ARIA labels and roles
- Screen reader optimization
- Focus management
- Reduced motion support
- High contrast mode

**Animation Tasks**:
- Framer Motion for transitions
- Loading skeletons
- Empty states
- Toast notifications
- Modal animations
- List reordering animations

**Responsive Tasks**:
- Mobile: 320px-768px (stacked layout)
- Tablet: 768px-1024px (2-column layout)
- Desktop: 1024px+ (3-column layout)
- Touch-friendly targets (44px minimum)

---

## Testing Strategy

### Unit Tests (Vitest)
- Component rendering
- Store logic
- API client
- Utility functions

### Integration Tests
- User flows
- API integration
- Offline sync
- State management

### E2E Tests (Playwright)
- Critical paths
- Onboarding flow
- Focus card creation
- List operations

---

## Deployment Checklist

### Pre-deployment
- [ ] All tests passing
- [ ] No TypeScript errors
- [ ] No ESLint warnings
- [ ] Build succeeds locally
- [ ] Environment variables configured in Vercel
- [ ] API URL pointing to production

### Vercel Setup
1. Connect GitHub repo
2. Configure build settings:
   - Framework: Next.js
   - Build command: `pnpm build`
   - Output directory: `.next`
   - Install command: `pnpm install`
3. Add environment variables:
   - `NEXT_PUBLIC_API_URL`
4. Enable Edge Runtime for API routes
5. Configure caching headers
6. Set up preview deployments

### Post-deployment
- [ ] Test production URL
- [ ] Verify API connectivity
- [ ] Test offline functionality
- [ ] Check analytics
- [ ] Monitor error tracking

---

## Success Metrics

### Week 1 (Foundation)
- ✅ Project initialized
- ✅ Design system configured
- ✅ API client working
- ✅ Vercel preview deployed

### Week 2-3 (Features)
- ✅ All 4 main pages functional
- ✅ API integration complete
- ✅ Onboarding flow working

### Week 4 (Sync)
- ✅ Offline mode working
- ✅ No data loss
- ✅ Sync queue processing

### Week 5 (Polish)
- ✅ Lighthouse score >90
- ✅ WCAG 2.2 AA compliant
- ✅ Animations smooth (60fps)
- ✅ Production ready

---

## Handoff Notes for Agents

### For `react-nextjs-expert`:
- Follow Next.js 14 App Router conventions
- Use Server Components where possible
- Client Components only when needed (state, effects, interactivity)
- Implement proper error boundaries
- Use loading.tsx for Suspense fallbacks

### For `tailwind-frontend-expert`:
- Match iOS design system exactly
- Use design tokens from tailwind.config
- Mobile-first responsive design
- Dark mode only (no light mode)
- Consistent spacing (8px grid)

### For `ui-forge-prime`:
- Smooth animations (60fps)
- Micro-interactions on hover/click
- Loading states everywhere
- Empty states with personality
- Celebratory moments (confetti, success states)

### For `react-state-manager`:
- React Query for server state
- Zustand for UI state
- Optimistic updates
- Proper error handling
- Cache invalidation strategy

### For `backend-developer`:
- API client must match iOS DTOs
- IndexedDB for offline storage
- Sync queue with retry logic
- Background sync with Service Worker
- Conflict resolution (last-write-wins)

### For `performance-optimizer`:
- Code splitting by route
- Lazy load below fold
- Virtual scrolling for lists
- Image optimization (Next.js Image)
- Bundle size <200KB initial

### For `accessibility-auditor`:
- Keyboard nav everywhere
- ARIA labels proper
- Screen reader friendly
- Focus visible states
- Color contrast WCAG AA

---

## API Endpoint Summary

```
Lists:
GET    /v1/lists
GET    /v1/lists/board
POST   /v1/lists
PUT    /v1/lists/:id
DELETE /v1/lists/:id

Focus:
GET    /v1/focus/:date
POST   /v1/focus
PUT    /v1/focus/:id
POST   /v1/focus/generate

Suggestions:
GET    /v1/suggestions/structured-procrastination?limit=5

Anti-Todo:
GET    /v1/anti-todo/:date
POST   /v1/anti-todo
GET    /v1/anti-todo/summary
```

---

## File Structure Reference

```
apps/web/frontend/
├── app/
│   ├── layout.tsx                 # Root layout
│   ├── page.tsx                   # Redirect to /focus
│   ├── providers.tsx              # React Query provider
│   ├── globals.css                # Global styles
│   ├── lists/
│   │   ├── page.tsx               # Lists page
│   │   ├── loading.tsx            # Loading state
│   │   └── error.tsx              # Error boundary
│   ├── focus/
│   │   ├── page.tsx               # Focus page
│   │   ├── loading.tsx
│   │   └── error.tsx
│   ├── switch/
│   │   ├── page.tsx               # Suggestions page
│   │   ├── loading.tsx
│   │   └── error.tsx
│   ├── wins/
│   │   ├── page.tsx               # Anti-Todo page
│   │   ├── loading.tsx
│   │   └── error.tsx
│   ├── onboarding/
│   │   └── page.tsx               # Onboarding flow
│   └── settings/
│       └── page.tsx               # Settings
├── components/
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── TextField.tsx
│   │   ├── TextArea.tsx
│   │   ├── Tag.tsx
│   │   ├── LoadingIndicator.tsx
│   │   ├── Modal.tsx
│   │   ├── Sheet.tsx
│   │   ├── Checkbox.tsx
│   │   ├── Select.tsx
│   │   ├── Toast.tsx
│   │   ├── Badge.tsx
│   │   ├── Avatar.tsx
│   │   ├── Tabs.tsx
│   │   └── Progress.tsx
│   ├── lists/
│   │   ├── ListBoard.tsx
│   │   ├── ListColumn.tsx
│   │   ├── ListItem.tsx
│   │   ├── QuickCaptureModal.tsx
│   │   └── ItemDetailModal.tsx
│   ├── focus/
│   │   ├── FocusCard.tsx
│   │   ├── PlanningWizard.tsx
│   │   ├── ReflectionModal.tsx
│   │   └── FocusCardCalendar.tsx
│   ├── suggestions/
│   │   ├── SuggestionCard.tsx
│   │   └── SuggestionList.tsx
│   ├── anti-todo/
│   │   ├── WinTimeline.tsx
│   │   ├── WinEntry.tsx
│   │   ├── AddWinModal.tsx
│   │   └── WinsSummary.tsx
│   └── onboarding/
│       ├── WelcomeScreen.tsx
│       ├── ProblemScreen.tsx
│       └── ... (12 screens total)
├── lib/
│   ├── api-client.ts              # API client + types
│   ├── store.ts                   # Zustand store
│   ├── db.ts                      # IndexedDB wrapper
│   ├── sync-service.ts            # Sync logic
│   └── utils.ts                   # Utilities
├── styles/
│   ├── globals.css                # Global CSS
│   └── tokens.css                 # Design tokens
├── public/
│   ├── icons/                     # SVG icons
│   └── images/                    # Images
├── tests/
│   ├── unit/
│   │   ├── components/
│   │   └── utils/
│   └── e2e/
│       └── flows/
├── .storybook/
│   └── main.ts
├── package.json
├── tailwind.config.ts
├── vercel.json
├── tsconfig.json
├── next.config.js
└── README.md
```

---

## Next Steps After Roadmap Creation

1. **Initialize Project**: Run Phase 1 Task 1.1 to create Next.js project
2. **Configure Tooling**: Set up Tailwind, Vercel, API client
3. **Build Components**: Create design system component library
4. **Implement Features**: Build pages in order (Lists → Focus → Switch → Wins)
5. **Add Onboarding**: Translate iOS onboarding flow
6. **Offline Support**: Implement sync and IndexedDB
7. **Polish**: Animations, accessibility, performance
8. **Deploy**: Push to Vercel production

---

## Contact & Support

For questions about this roadmap:
- Check iOS implementation: `apps/ios/AndreApp/`
- Review design system: `apps/ios/AndreApp/Sources/AndreApp/DesignSystem/`
- API reference: `services/api/src/routes/`
- Product brief: `docs/product_brief.md`

**Good luck building Andre Web!** 🚀
