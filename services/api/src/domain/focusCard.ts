import { z } from "zod";
import { ListItemSchema } from "./listItem.js";

export const EnergyBudgetSchema = z.enum(["high", "medium", "low"]);
export type EnergyBudget = z.infer<typeof EnergyBudgetSchema>;

export const FocusMetaSchema = z.object({
  theme: z.string().default(""),
  energyBudget: EnergyBudgetSchema.default("medium"),
  successMetric: z.string().default("")
});

export const IsoDateSchema = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, "Expected YYYY-MM-DD date string");

export const DailyFocusCardSchema = z.object({
  id: z.string().uuid(),
  date: IsoDateSchema,
  items: z.array(ListItemSchema),
  meta: FocusMetaSchema,
  reflection: z.string().optional()
});
export type DailyFocusCard = z.infer<typeof DailyFocusCardSchema>;

export const GenerateFocusCardPayloadSchema = z.object({
  date: IsoDateSchema.default(() => new Date().toISOString().slice(0, 10)),
  deviceId: z.string().optional()
});
export type GenerateFocusCardPayload = z.infer<typeof GenerateFocusCardPayloadSchema>;

export const AntiTodoEntrySchema = z.object({
  id: z.string().uuid().optional(),
  title: z.string().min(1),
  completedAt: z.string().datetime().default(() => new Date().toISOString())
});
export type AntiTodoEntry = z.infer<typeof AntiTodoEntrySchema>;
