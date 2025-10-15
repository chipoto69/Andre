import { describe, expect, it } from "vitest";
import { ClassificationService } from "../src/services/classificationService.js";

describe("ClassificationService", () => {
  const service = new ClassificationService();

  it("classifies follow up tasks as watch", () => {
    const result = service.classify("Follow up with Sarah about partnership");
    expect(result.suggestedListType).toBe("watch");
    expect(result.confidence).toBeGreaterThan(0.6);
  });

  it("classifies research tasks as later", () => {
    const result = service.classify("Research calendar integration options");
    expect(result.suggestedListType).toBe("later");
  });

  it("falls back to todo when unsure", () => {
    const result = service.classify("Do stuff");
    expect(result.suggestedListType).toBe("todo");
    expect(result.source).toBe("fallback");
  });
});
