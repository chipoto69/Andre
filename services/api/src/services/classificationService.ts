const TODO_KEYWORDS = [
  "finish",
  "complete",
  "write",
  "send",
  "review",
  "prepare",
  "draft",
  "deliver",
  "submit"
];

const WATCH_KEYWORDS = [
  "call",
  "follow up",
  "check in",
  "wait for",
  "remind",
  "confirm",
  "ping",
  "email",
  "reach out"
];

const LATER_KEYWORDS = [
  "research",
  "explore",
  "consider",
  "look into",
  "maybe",
  "someday",
  "idea",
  "learn",
  "plan"
];

type ClassificationSource = "keyword" | "fallback";

export interface ClassificationResult {
  suggestedListType: "todo" | "watch" | "later";
  confidence: number;
  reasoning?: string;
  source: ClassificationSource;
  alternatives: Array<{
    listType: "todo" | "watch" | "later";
    confidence: number;
  }>;
}

export class ClassificationService {
  classify(text: string): ClassificationResult {
    const lowered = text.toLowerCase();

    const scores: Record<"todo" | "watch" | "later", number> = {
      todo: keywordScore(lowered, TODO_KEYWORDS),
      watch: keywordScore(lowered, WATCH_KEYWORDS),
      later: keywordScore(lowered, LATER_KEYWORDS)
    };

    const bestEntry = Object.entries(scores).sort((a, b) => b[1] - a[1])[0] as
      | ["todo" | "watch" | "later", number]
      | undefined;

    if (!bestEntry || bestEntry[1] === 0) {
      return {
        suggestedListType: "todo",
        confidence: 0.4,
        source: "fallback",
        reasoning: "Defaulted to todo when no strong signals were detected.",
        alternatives: buildAlternatives(scores, "todo")
      };
    }

    const [listType, score] = bestEntry;
    const confidence = Math.min(0.9, 0.6 + score);

    return {
      suggestedListType: listType,
      confidence,
      source: "keyword",
      reasoning: `Matched keywords for ${listType}.`,
      alternatives: buildAlternatives(scores, listType)
    };
  }
}

function keywordScore(text: string, keywords: string[]): number {
  let score = 0;
  for (const keyword of keywords) {
    if (text.includes(keyword)) {
      score += keyword.split(" ").length > 1 ? 0.25 : 0.2;
    }
  }
  return score;
}

function buildAlternatives(
  scores: Record<"todo" | "watch" | "later", number>,
  primary: "todo" | "watch" | "later"
) {
  return (Object.entries(scores) as Array<["todo" | "watch" | "later", number]>)
    .filter(([listType]) => listType !== primary)
    .map(([listType, rawScore]) => ({
      listType,
      confidence: Math.min(0.9, 0.5 + rawScore)
    }))
    .sort((a, b) => b.confidence - a.confidence);
}
