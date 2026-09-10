import { CATEGORIES, PASS_RATIO, SUBJECTS, categoryMeta } from "../types";
import type { CategoryId, ChoiceIndex, Question, SubjectId } from "../types";
import { shuffle } from "./random";
import type { Rng } from "./random";

/** 問題IDごとの回答（未回答は undefined） */
export type Answers = Readonly<Record<string, ChoiceIndex | undefined>>;

export interface SubjectScore {
  readonly subject: SubjectId;
  readonly label: string;
  readonly correct: number;
  readonly total: number;
  readonly points: number;
  readonly maxPoints: number;
  readonly ratio: number;
  readonly passed: boolean;
}

export interface CategoryScore {
  readonly category: CategoryId;
  readonly correct: number;
  readonly total: number;
}

export interface ExamScore {
  readonly subjects: readonly SubjectScore[];
  readonly categories: readonly CategoryScore[];
  readonly correct: number;
  readonly total: number;
  /** 出題された全科目で合格基準を満たしたか */
  readonly passed: boolean;
}

/** 分野ごとに出題数ぶんを抽出する。バンクが足りない分野はある分だけ出す */
export function buildExam(bank: readonly Question[], rng: Rng = Math.random): Question[] {
  return CATEGORIES.flatMap((meta) => {
    const pool = bank.filter((q) => q.category === meta.id);
    return shuffle(pool, rng).slice(0, meta.examCount);
  });
}

/** 分野別ドリル。category が null なら全分野から */
export function buildDrill(
  bank: readonly Question[],
  category: CategoryId | null,
  count: number,
  rng: Rng = Math.random,
): Question[] {
  const pool = category === null ? bank : bank.filter((q) => q.category === category);
  return shuffle(pool, rng).slice(0, Math.max(0, count));
}

export function isCorrect(question: Question, answer: ChoiceIndex | undefined): boolean {
  return answer !== undefined && answer === question.answer;
}

export function scoreExam(questions: readonly Question[], answers: Answers): ExamScore {
  const categories: CategoryScore[] = CATEGORIES.flatMap((meta) => {
    const qs = questions.filter((q) => q.category === meta.id);
    if (qs.length === 0) return [];
    const correct = qs.filter((q) => isCorrect(q, answers[q.id])).length;
    return [{ category: meta.id, correct, total: qs.length }];
  });

  const subjects: SubjectScore[] = SUBJECTS.flatMap((subject) => {
    const rows = categories.filter((c) => subject.categories.includes(c.category));
    if (rows.length === 0) return [];
    const points = rows.reduce((sum, r) => sum + r.correct * categoryMeta(r.category).points, 0);
    const maxPoints = rows.reduce((sum, r) => sum + r.total * categoryMeta(r.category).points, 0);
    const correct = rows.reduce((sum, r) => sum + r.correct, 0);
    const total = rows.reduce((sum, r) => sum + r.total, 0);
    const ratio = maxPoints === 0 ? 0 : points / maxPoints;
    return [
      {
        subject: subject.id,
        label: subject.label,
        correct,
        total,
        points,
        maxPoints,
        ratio,
        passed: ratio >= PASS_RATIO,
      },
    ];
  });

  const correct = categories.reduce((sum, c) => sum + c.correct, 0);
  const total = categories.reduce((sum, c) => sum + c.total, 0);
  const passed = subjects.length > 0 && subjects.every((s) => s.passed);
  return { subjects, categories, correct, total, passed };
}
