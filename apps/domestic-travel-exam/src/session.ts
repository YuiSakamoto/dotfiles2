import type { CategoryId, Question } from "./types";

export type Mode = "exam" | "drill" | "review";

export interface Session {
  readonly mode: Mode;
  readonly category: CategoryId | null;
  readonly questions: readonly Question[];
  readonly startedAt: number;
}

export const MODE_LABEL: Record<Mode, string> = {
  exam: "模擬試験",
  drill: "分野別ドリル",
  review: "弱点復習",
};
