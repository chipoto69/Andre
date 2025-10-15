import { z } from "zod";
import { ListItemSchema, ListTypeSchema } from "./listItem.js";

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
  usedAiSuggestions: z.boolean().default(false),
  reflection: z.string().optional()
});
export type DailyFocusCard = z.infer<typeof DailyFocusCardSchema>;

export const FocusCandidateItemSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  listType: ListTypeSchema,
  dueAt: z.string().datetime().optional(),
  priority: z.number().int().min(1).max(5).optional()
});
export type FocusCandidateItem = z.infer<typeof FocusCandidateItemSchema>;

export const FocusCardContextSchema = z.object({
  calendarEvents: z
    .array(
      z.object({
        title: z.string().min(1),
        startTime: z.string().datetime(),
        endTime: z.string().datetime()
      })
    )
    .optional(),
  historicalCompletionRate: z.number().min(0).max(1).optional(),
  averageEnergyLevel: EnergyBudgetSchema.optional()
});
export type FocusCardContext = z.infer<typeof FocusCardContextSchema>;

export const GenerateFocusCardRequestSchema = z.object({
  userId: z.string().min(1),
  targetDate: IsoDateSchema.default(() => new Date().toISOString().slice(0, 10)),
  availableItems: z.array(FocusCandidateItemSchema).optional(),
  context: FocusCardContextSchema.optional()
});
export type GenerateFocusCardRequest = z.infer<typeof GenerateFocusCardRequestSchema>;

export const FocusCardReasoningSchema = z.object({
  itemSelection: z.string(),
  themeRationale: z.string(),
  energyEstimate: z.string()
});
export type FocusCardReasoning = z.infer<typeof FocusCardReasoningSchema>;

export const FocusCardSuggestionSchema = z.object({
  suggestedItems: z.array(z.string().min(1)).min(0).max(5),
  theme: z.string().min(1),
  energyBudget: EnergyBudgetSchema,
  successMetric: z.string().min(1),
  reasoning: FocusCardReasoningSchema
});
export type FocusCardSuggestion = z.infer<typeof FocusCardSuggestionSchema>;

export const AntiTodoEntrySchema = z.object({
  id: z.string().uuid().optional(),
  title: z.string().min(1),
  completedAt: z.string().datetime().default(() => new Date().toISOString())
});
export type AntiTodoEntry = z.infer<typeof AntiTodoEntrySchema>;
