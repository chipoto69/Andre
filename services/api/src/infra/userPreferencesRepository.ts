import { type Database } from "better-sqlite3";
import type { UserPreferences } from "../domain/userPreferences.js";

export class UserPreferencesRepository {
  constructor(private readonly db: Database) {}

  get(userId: string): UserPreferences | null {
    const row = this.db
      .prepare(
        `SELECT
            user_id as userId,
            planning_time as planningTime,
            planning_hour as planningHour,
            notifications_enabled as notificationsEnabled,
            timezone,
            onboarding_completed_at as onboardingCompletedAt,
            onboarding_version as onboardingVersion
         FROM user_preferences WHERE user_id = ?`
      )
      .get(userId) as (UserPreferences & { notificationsEnabled: 0 | 1 }) | undefined;

    if (!row) return null;
    return {
      ...row,
      notificationsEnabled: Boolean(row.notificationsEnabled)
    };
  }

  create(preferences: UserPreferences): void {
    this.db
      .prepare(
        `INSERT INTO user_preferences (
            user_id,
            planning_time,
            planning_hour,
            notifications_enabled,
            timezone,
            onboarding_completed_at,
            onboarding_version
         ) VALUES (
            @userId,
            @planningTime,
            @planningHour,
            @notificationsEnabled,
            @timezone,
            @onboardingCompletedAt,
            @onboardingVersion
         )`
      )
      .run(coerceForSql(preferences, true));
  }

  upsert(preferences: UserPreferences): void {
    this.db
      .prepare(
        `INSERT INTO user_preferences (
            user_id,
            planning_time,
            planning_hour,
            notifications_enabled,
            timezone,
            onboarding_completed_at,
            onboarding_version
         ) VALUES (
            @userId,
            @planningTime,
            @planningHour,
            @notificationsEnabled,
            @timezone,
            @onboardingCompletedAt,
            @onboardingVersion
         )
         ON CONFLICT(user_id) DO UPDATE SET
            planning_time = excluded.planning_time,
            planning_hour = excluded.planning_hour,
            notifications_enabled = excluded.notifications_enabled,
            timezone = excluded.timezone,
            onboarding_completed_at = excluded.onboarding_completed_at,
            onboarding_version = excluded.onboarding_version`
      )
      .run(coerceForSql(preferences));
  }
}

function coerceForSql(input: UserPreferences, requireCompletedAt = false) {
  return {
    ...input,
    planningHour: input.planningHour ?? null,
    notificationsEnabled: input.notificationsEnabled ? 1 : 0,
    onboardingCompletedAt:
      input.onboardingCompletedAt ?? (requireCompletedAt ? new Date().toISOString() : null)
  };
}
