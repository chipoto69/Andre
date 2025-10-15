import { z } from "zod";

export const PlanningTimeSchema = z.enum(["morning", "evening", "custom"]);

export const UserPreferencesSchema = z
  .object({
    userId: z.string().min(1),
    planningTime: PlanningTimeSchema,
    planningHour: z
      .number()
      .int()
      .min(0)
      .max(23)
      .optional(),
    notificationsEnabled: z.boolean().default(true),
    timezone: z.string().min(1).default("UTC"),
    onboardingCompletedAt: z.string().datetime().optional(),
    onboardingVersion: z.string().default("3.0")
  })
  .refine(
    (data) => (data.planningTime === "custom" ? data.planningHour !== undefined : true),
    {
      message: "planningHour is required when planningTime is 'custom'",
      path: ["planningHour"]
    }
  );

export type UserPreferences = z.infer<typeof UserPreferencesSchema>;

export const UpsertUserPreferencesSchema = UserPreferencesSchema;

export const GetUserPreferencesQuerySchema = z.object({
  userId: z.string().min(1)
});

export type GetUserPreferencesQuery = z.infer<typeof GetUserPreferencesQuerySchema>;
