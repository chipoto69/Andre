import { z } from "zod";

export const ListTypeSchema = z.enum(["todo", "watch", "later", "antiTodo"]);
export type ListType = z.infer<typeof ListTypeSchema>;

export const ListStatusSchema = z.enum([
  "planned",
  "in_progress",
  "completed",
  "archived"
]);
export type ListStatus = z.infer<typeof ListStatusSchema>;

export const ListItemSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  listType: ListTypeSchema,
  status: ListStatusSchema.default("planned"),
  notes: z.string().max(2000).optional(),
  dueAt: z.string().datetime().optional(),
  followUpAt: z.string().datetime().optional(),
  createdAt: z.string().datetime(),
  completedAt: z.string().datetime().nullable().optional(),
  tags: z.array(z.string()).default([]),
  confidenceScore: z.number().min(0).max(1).default(0.5)
});
export type ListItem = z.infer<typeof ListItemSchema>;

export const NewListItemSchema = ListItemSchema.partial({
  id: true,
  createdAt: true,
  status: true,
  tags: true,
  confidenceScore: true
})
  .extend({
    title: z.string().min(1),
    listType: ListTypeSchema
  })
  .transform((payload) => ({
    id: payload.id ?? crypto.randomUUID(),
    createdAt: payload.createdAt ?? new Date().toISOString(),
    status: payload.status ?? "planned",
    tags: payload.tags ?? [],
    confidenceScore: payload.confidenceScore ?? 0.5,
    ...payload
  }));
export type NewListItem = z.infer<typeof NewListItemSchema>;

export const UpdateListItemSchema = ListItemSchema.partial({
  id: true,
  createdAt: true
});
export type UpdateListItem = z.infer<typeof UpdateListItemSchema>;
