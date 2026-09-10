import type { CategoryId, Question, Result } from "../types";
import type { ExamScore } from "./exam";

/** 問題ごとの学習履歴 */
export interface QuestionRecord {
  readonly attempts: number;
  readonly correct: number;
  readonly lastCorrect: boolean;
  readonly lastAt: number;
}

export interface ExamHistoryEntry {
  readonly at: number;
  readonly mode: "exam" | "drill" | "review";
  readonly category: CategoryId | null;
  readonly correct: number;
  readonly total: number;
  readonly passed: boolean | null;
  readonly subjects: ReadonlyArray<{ label: string; points: number; maxPoints: number }>;
}

export interface Progress {
  readonly records: Readonly<Record<string, QuestionRecord>>;
  readonly history: readonly ExamHistoryEntry[];
}

export const EMPTY_PROGRESS: Progress = { records: {}, history: [] };

const KEY = "domestic-travel-exam:progress:v1";
const HISTORY_LIMIT = 50;

interface StorageLike {
  getItem(key: string): string | null;
  setItem(key: string, value: string): void;
  removeItem(key: string): void;
}

function defaultStorage(): StorageLike | null {
  try {
    return typeof localStorage === "undefined" ? null : localStorage;
  } catch {
    // プライベートモード等で accessor 自体が throw するケース
    return null;
  }
}

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

/** 壊れた JSON や古い形式は空の進捗として扱う（例外は投げない） */
export function parseProgress(raw: string | null): Result<Progress> {
  if (raw === null) return { ok: true, value: EMPTY_PROGRESS };
  try {
    const parsed: unknown = JSON.parse(raw);
    if (!isRecord(parsed) || !isRecord(parsed.records) || !Array.isArray(parsed.history)) {
      return { ok: false, error: "unexpected shape" };
    }
    return { ok: true, value: parsed as unknown as Progress };
  } catch (e) {
    return { ok: false, error: e instanceof Error ? e.message : "parse error" };
  }
}

export function loadProgress(storage: StorageLike | null = defaultStorage()): Progress {
  if (storage === null) return EMPTY_PROGRESS;
  try {
    const parsed = parseProgress(storage.getItem(KEY));
    return parsed.ok ? parsed.value : EMPTY_PROGRESS;
  } catch {
    return EMPTY_PROGRESS;
  }
}

export function saveProgress(progress: Progress, storage: StorageLike | null = defaultStorage()): Result<void> {
  if (storage === null) return { ok: false, error: "storage unavailable" };
  try {
    storage.setItem(KEY, JSON.stringify(progress));
    return { ok: true, value: undefined };
  } catch (e) {
    return { ok: false, error: e instanceof Error ? e.message : "write error" };
  }
}

export function clearProgress(storage: StorageLike | null = defaultStorage()): void {
  try {
    storage?.removeItem(KEY);
  } catch {
    // 消せなくても致命的ではない
  }
}

export function recordAnswer(progress: Progress, questionId: string, correct: boolean, now: number): Progress {
  const prev = progress.records[questionId];
  const next: QuestionRecord = {
    attempts: (prev?.attempts ?? 0) + 1,
    correct: (prev?.correct ?? 0) + (correct ? 1 : 0),
    lastCorrect: correct,
    lastAt: now,
  };
  return { ...progress, records: { ...progress.records, [questionId]: next } };
}

export function appendHistory(
  progress: Progress,
  entry: Omit<ExamHistoryEntry, "subjects" | "passed"> & { score: ExamScore; graded: boolean },
): Progress {
  const { score, graded, ...rest } = entry;
  const history: ExamHistoryEntry = {
    ...rest,
    passed: graded ? score.passed : null,
    subjects: score.subjects.map((s) => ({ label: s.label, points: s.points, maxPoints: s.maxPoints })),
  };
  return { ...progress, history: [history, ...progress.history].slice(0, HISTORY_LIMIT) };
}

/** 弱点 = 直近が不正解、または正答率 50% 未満 */
export function isWeak(record: QuestionRecord | undefined): boolean {
  if (record === undefined) return false;
  return !record.lastCorrect || record.correct / record.attempts < 0.5;
}

export function weakQuestions(bank: readonly Question[], progress: Progress): Question[] {
  return bank.filter((q) => isWeak(progress.records[q.id]));
}

export interface CategoryStats {
  readonly answered: number;
  readonly total: number;
  readonly attempts: number;
  readonly correct: number;
}

export function categoryStats(bank: readonly Question[], progress: Progress, category: CategoryId): CategoryStats {
  const qs = bank.filter((q) => q.category === category);
  return qs.reduce<CategoryStats>(
    (acc, q) => {
      const r = progress.records[q.id];
      if (r === undefined) return acc;
      return {
        answered: acc.answered + 1,
        total: acc.total,
        attempts: acc.attempts + r.attempts,
        correct: acc.correct + r.correct,
      };
    },
    { answered: 0, total: qs.length, attempts: 0, correct: 0 },
  );
}
