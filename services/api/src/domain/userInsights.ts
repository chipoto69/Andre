import { z } from "zod";

export const CompletionPatternsSchema = z.object({
  bestDayOfWeek: z.string(),
  bestTimeOfDay: z.enum(["morning", "afternoon", "evening"]),
  averageCompletionRate: z.number().min(0).max(1),
  streak: z.number().int().min(0)
});
export type CompletionPatterns = z.infer<typeof CompletionPatternsSchema>;

export const ListHealthSchema = z.object({
  todo: z.object({
    count: z.number().int().min(0),
    staleItems: z.number().int().min(0)
  }),
  watch: z.object({
    count: z.number().int().min(0),
    avgDwellTime: z.number().min(0)
  }),
  later: z.object({
    count: z.number().int().min(0),
    staleItems: z.number().int().min(0)
  })
});
export type ListHealth = z.infer<typeof ListHealthSchema>;

export const InsightSuggestionSchema = z.object({
  type: z.enum(["insight", "warning", "encouragement"]),
  message: z.string(),
  actionable: z.boolean()
});
export type InsightSuggestion = z.infer<typeof InsightSuggestionSchema>;

export const UserInsightsSchema = z.object({
  completionPatterns: CompletionPatternsSchema,
  listHealth: ListHealthSchema,
  suggestions: z.array(InsightSuggestionSchema)
});
export type UserInsights = z.infer<typeof UserInsightsSchema>;
