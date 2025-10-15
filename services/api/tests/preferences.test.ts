import { beforeEach, describe, expect, it } from "vitest";
import { connect, resetDatabase, getDbInstance } from "../src/infra/sqlite.js";
import { UserPreferencesRepository } from "../src/infra/userPreferencesRepository.js";
import { PreferencesService } from "../src/services/preferencesService.js";

const basePreferences = {
  userId: "user-123",
  planningTime: "evening" as const,
  planningHour: 19,
  notificationsEnabled: true,
  timezone: "America/Los_Angeles",
  onboardingCompletedAt: "2025-10-15T20:30:00Z",
  onboardingVersion: "3.0"
};

describe("PreferencesService", () => {
  let service: PreferencesService;

  beforeEach(() => {
    connect({ memory: true });
    resetDatabase();
    const repo = new UserPreferencesRepository(getDbInstance());
    service = new PreferencesService(repo);
  });

  it("creates and retrieves user preferences", () => {
    service.create(basePreferences);
    const stored = service.get(basePreferences.userId);
    expect(stored).toBeDefined();
    expect(stored?.planningTime).toBe("evening");
  });

  it("upserts preferences", () => {
    service.upsert(basePreferences);
    service.upsert({
      ...basePreferences,
      planningTime: "morning",
      planningHour: 8
    });

    const stored = service.get(basePreferences.userId);
    expect(stored?.planningTime).toBe("morning");
    expect(stored?.planningHour).toBe(8);
  });

  it("throws when creating duplicate preferences", () => {
    service.create(basePreferences);
    try {
      service.create(basePreferences);
      expect.fail("Expected creating duplicate preferences to throw");
    } catch (error) {
      expect((error as Error).message).toBe("Preferences already exist for user");
    }
  });
});
