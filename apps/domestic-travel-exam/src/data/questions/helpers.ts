import type { CategoryId, ChoiceIndex, Question } from "../../types";

type Choices = readonly [string, string, string, string];

/** 分野を固定した問題ファクトリ。ID は分野プレフィックス＋連番で一意にする */
export function questionFactory(category: CategoryId, prefix: string) {
  return (n: number, question: string, choices: Choices, answer: ChoiceIndex, explanation: string): Question => ({
    id: `${prefix}-${String(n).padStart(3, "0")}`,
    category,
    question,
    choices,
    answer,
    explanation,
  });
}
