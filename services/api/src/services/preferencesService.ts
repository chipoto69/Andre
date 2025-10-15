import type { UserPreferences } from "../domain/userPreferences.js";
import { UserPreferencesRepository } from "../infra/userPreferencesRepository.js";

export class PreferencesService {
  constructor(private readonly repository: UserPreferencesRepository) {}

  get(userId: string): UserPreferences | null {
    return this.repository.get(userId);
  }

  create(preferences: UserPreferences): void {
    const existing = this.repository.get(preferences.userId);
    if (existing) {
      throw new Error("Preferences already exist for user");
    }
    this.repository.create(preferences);
  }

  upsert(preferences: UserPreferences): void {
    this.repository.upsert(preferences);
  }
}
