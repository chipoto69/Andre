import { z } from "zod";
import { ListTypeSchema } from "./listItem.js";

export const SuggestionSourceSchema = z.enum(["later", "watch", "momentum"]);
export type SuggestionSource = z.infer<typeof SuggestionSourceSchema>;

export const SuggestionSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  listType: ListTypeSchema,
  score: z.number().min(0).max(1),
  source: SuggestionSourceSchema
});
export type Suggestion = z.infer<typeof SuggestionSchema>;

export const SuggestionListSchema = z.array(SuggestionSchema);
