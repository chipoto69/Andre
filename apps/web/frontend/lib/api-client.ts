import { z } from 'zod';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

// ============================================================================
// Domain Schemas (matching backend)
// ============================================================================

export const ListTypeSchema = z.enum(['todo', 'watch', 'later', 'antiTodo']);
export type ListType = z.infer<typeof ListTypeSchema>;

export const ListStatusSchema = z.enum([
  'planned',
  'in_progress',
  'completed',
  'archived',
]);
export type ListStatus = z.infer<typeof ListStatusSchema>;

export const ListItemSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  listType: ListTypeSchema,
  status: ListStatusSchema,
  notes: z.string().max(2000).optional(),
  dueAt: z.string().datetime().optional(),
  followUpAt: z.string().datetime().optional(),
  createdAt: z.string().datetime(),
  completedAt: z.string().datetime().nullable().optional(),
  tags: z.array(z.string()),
  confidenceScore: z.number().min(0).max(1),
});
export type ListItem = z.infer<typeof ListItemSchema>;

export const EnergyBudgetSchema = z.enum(['high', 'medium', 'low']);
export type EnergyBudget = z.infer<typeof EnergyBudgetSchema>;

export const FocusMetaSchema = z.object({
  theme: z.string(),
  energyBudget: EnergyBudgetSchema,
  successMetric: z.string(),
});
export type FocusMeta = z.infer<typeof FocusMetaSchema>;

export const DailyFocusCardSchema = z.object({
  id: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  items: z.array(ListItemSchema),
  meta: FocusMetaSchema,
  reflection: z.string().optional(),
});
export type DailyFocusCard = z.infer<typeof DailyFocusCardSchema>;

export const SuggestionSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  listType: ListTypeSchema,
  score: z.number().min(0).max(1),
  source: z.enum(['later', 'watch', 'momentum']),
});
export type Suggestion = z.infer<typeof SuggestionSchema>;

export const AntiTodoEntrySchema = z.object({
  id: z.string().uuid(),
  title: z.string(),
  completedAt: z.string().datetime(),
});
export type AntiTodoEntry = z.infer<typeof AntiTodoEntrySchema>;

export const BoardSchema = z.object({
  todo: z.array(ListItemSchema),
  watch: z.array(ListItemSchema),
  later: z.array(ListItemSchema),
});
export type Board = z.infer<typeof BoardSchema>;

// Payload schemas for API operations
export const CreateListItemPayloadSchema = z.object({
  title: z.string().min(1),
  listType: ListTypeSchema,
  notes: z.string().max(2000).optional(),
  dueAt: z.string().datetime().optional(),
  followUpAt: z.string().datetime().optional(),
  tags: z.array(z.string()).optional(),
});
export type CreateListItemPayload = z.infer<typeof CreateListItemPayloadSchema>;

// ============================================================================
// API Client
// ============================================================================

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
      const errorText = await response.text();
      throw new Error(
        `API Error (${response.status}): ${errorText || response.statusText}`
      );
    }

    // Handle 204 No Content
    if (response.status === 204) {
      return null as T;
    }

    return response.json();
  }

  // ============================================================================
  // Lists API
  // ============================================================================

  async getBoard(): Promise<Board> {
    const data = await this.request<unknown>('/v1/lists/sync');
    return BoardSchema.parse(data);
  }

  async createListItem(item: CreateListItemPayload): Promise<ListItem> {
    // Validate payload before sending to API
    const validatedPayload = CreateListItemPayloadSchema.parse(item);
    const data = await this.request<unknown>('/v1/lists', {
      method: 'POST',
      body: JSON.stringify(validatedPayload),
    });
    return ListItemSchema.parse(data);
  }

  async updateListItem(
    id: string,
    updates: Partial<Omit<ListItem, 'id' | 'createdAt'>>
  ): Promise<ListItem> {
    const data = await this.request<unknown>(`/v1/lists/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    });
    return ListItemSchema.parse(data);
  }

  async deleteListItem(id: string): Promise<void> {
    await this.request<void>(`/v1/lists/${id}`, {
      method: 'DELETE',
    });
  }

  // ============================================================================
  // Focus Cards API
  // ============================================================================

  async getFocusCard(date: string): Promise<DailyFocusCard | null> {
    try {
      const data = await this.request<unknown>(`/v1/focus/${date}`);
      return DailyFocusCardSchema.parse(data);
    } catch (error) {
      // Return null if not found (404)
      if (error instanceof Error && error.message.includes('404')) {
        return null;
      }
      throw error;
    }
  }

  async createFocusCard(
    card: Omit<DailyFocusCard, 'id'>
  ): Promise<DailyFocusCard> {
    const data = await this.request<unknown>('/v1/focus', {
      method: 'POST',
      body: JSON.stringify(card),
    });
    return DailyFocusCardSchema.parse(data);
  }

  async updateFocusCard(
    id: string,
    updates: Partial<Omit<DailyFocusCard, 'id'>>
  ): Promise<DailyFocusCard> {
    const data = await this.request<unknown>(`/v1/focus/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
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

  // ============================================================================
  // Suggestions API
  // ============================================================================

  async getSuggestions(limit: number = 5): Promise<Suggestion[]> {
    const data = await this.request<unknown>(
      `/v1/suggestions/structured-procrastination?limit=${limit}`
    );
    return z.array(SuggestionSchema).parse(data);
  }

  // ============================================================================
  // Anti-Todo API
  // ============================================================================

  async getAntiTodoEntries(date: string): Promise<AntiTodoEntry[]> {
    const data = await this.request<unknown>(`/v1/anti-todo/${date}`);
    return z.array(AntiTodoEntrySchema).parse(data);
  }

  async logAntiTodoEntry(
    entry: Omit<AntiTodoEntry, 'id' | 'completedAt'>
  ): Promise<AntiTodoEntry> {
    const data = await this.request<unknown>('/v1/anti-todo', {
      method: 'POST',
      body: JSON.stringify(entry),
    });
    return AntiTodoEntrySchema.parse(data);
  }

  async getAntiTodoSummary(date: string): Promise<{
    count: number;
    entries: AntiTodoEntry[];
  }> {
    const data = await this.request<unknown>(`/v1/anti-todo/summary?date=${date}`);
    return z
      .object({
        count: z.number(),
        entries: z.array(AntiTodoEntrySchema),
      })
      .parse(data);
  }
}

export const apiClient = new ApiClient();
