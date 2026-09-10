import { describe, expect, it } from "vitest";
import { QUESTIONS } from "../data/questions";
import { scoreExam } from "./exam";
import {
  EMPTY_PROGRESS,
  appendHistory,
  categoryStats,
  isWeak,
  loadProgress,
  parseProgress,
  recordAnswer,
  saveProgress,
  weakQuestions,
} from "./storage";

function memoryStorage() {
  const map = new Map<string, string>();
  return {
    getItem: (k: string) => map.get(k) ?? null,
    setItem: (k: string, v: string) => void map.set(k, v),
    removeItem: (k: string) => void map.delete(k),
  };
}

describe("parseProgress", () => {
  it("null は空の進捗", () => {
    expect(parseProgress(null)).toEqual({ ok: true, value: EMPTY_PROGRESS });
  });
  it("壊れた JSON はエラーを返し、throw しない", () => {
    expect(parseProgress("{oops").ok).toBe(false);
    expect(parseProgress('{"records":[]}').ok).toBe(false);
  });
});

describe("recordAnswer / isWeak", () => {
  it("回数と正解数を積み上げる", () => {
    const p1 = recordAnswer(EMPTY_PROGRESS, "x", false, 1);
    const p2 = recordAnswer(p1, "x", true, 2);
    expect(p2.records.x).toEqual({ attempts: 2, correct: 1, lastCorrect: true, lastAt: 2 });
    expect(p1.records.x?.attempts).toBe(1);
  });
  it("直近不正解、または正答率 50% 未満なら弱点", () => {
    expect(isWeak(undefined)).toBe(false);
    expect(isWeak({ attempts: 1, correct: 0, lastCorrect: false, lastAt: 0 })).toBe(true);
    expect(isWeak({ attempts: 4, correct: 1, lastCorrect: true, lastAt: 0 })).toBe(true);
    expect(isWeak({ attempts: 2, correct: 1, lastCorrect: true, lastAt: 0 })).toBe(false);
  });
});

describe("save / load", () => {
  it("往復で同じ内容になる", () => {
    const storage = memoryStorage();
    const p = recordAnswer(EMPTY_PROGRESS, "gyoho-001", true, 10);
    expect(saveProgress(p, storage).ok).toBe(true);
    expect(loadProgress(storage)).toEqual(p);
  });
  it("storage が無ければ空を返し、保存は失敗を返す", () => {
    expect(loadProgress(null)).toEqual(EMPTY_PROGRESS);
    expect(saveProgress(EMPTY_PROGRESS, null).ok).toBe(false);
  });
});

describe("history / stats", () => {
  it("履歴は先頭に追加され上限で切り詰められる", () => {
    const qs = QUESTIONS.slice(0, 2);
    const score = scoreExam(qs, {});
    const base = { mode: "drill" as const, category: null, correct: 0, total: 2, score, graded: false };
    const p = Array.from({ length: 60 }).reduce<typeof EMPTY_PROGRESS>((acc, _, i) => appendHistory(acc, { ...base, at: i }), EMPTY_PROGRESS);
    expect(p.history).toHaveLength(50);
    expect(p.history[0]?.at).toBe(59);
    expect(p.history[0]?.passed).toBeNull();
  });
  it("分野統計と弱点抽出", () => {
    const first = QUESTIONS.find((q) => q.category === "chiri");
    if (first === undefined) throw new Error("chiri question missing");
    const p = recordAnswer(EMPTY_PROGRESS, first.id, false, 1);
    const stats = categoryStats(QUESTIONS, p, "chiri");
    expect(stats.answered).toBe(1);
    expect(stats.attempts).toBe(1);
    expect(stats.correct).toBe(0);
    expect(weakQuestions(QUESTIONS, p).map((q) => q.id)).toEqual([first.id]);
  });
});
