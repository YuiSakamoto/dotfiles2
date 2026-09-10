import { describe, expect, it } from "vitest";
import { QUESTIONS } from "../data/questions";
import { CATEGORIES } from "../types";
import type { Question } from "../types";
import { buildDrill, buildExam, scoreExam } from "./exam";
import { seededRng } from "./random";

const rng = () => seededRng(42);

describe("問題バンクの整合性", () => {
  it("ID が一意である", () => {
    const ids = QUESTIONS.map((q) => q.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it("選択肢は4つで、正答インデックスが範囲内、選択肢が重複しない", () => {
    for (const q of QUESTIONS) {
      expect(q.choices, q.id).toHaveLength(4);
      expect(q.answer, q.id).toBeGreaterThanOrEqual(0);
      expect(q.answer, q.id).toBeLessThanOrEqual(3);
      expect(new Set(q.choices).size, q.id).toBe(4);
      expect(q.question.trim().length, q.id).toBeGreaterThan(0);
      expect(q.explanation.trim().length, q.id).toBeGreaterThan(0);
    }
  });

  it("模擬試験に必要な問数が各分野にそろっている", () => {
    for (const meta of CATEGORIES) {
      const n = QUESTIONS.filter((q) => q.category === meta.id).length;
      expect(n, meta.id).toBeGreaterThanOrEqual(meta.examCount);
    }
  });
});

describe("buildExam", () => {
  it("分野ごとに規定数を分野順で出題する", () => {
    const exam = buildExam(QUESTIONS, rng());
    const expectedTotal = CATEGORIES.reduce((s, c) => s + c.examCount, 0);
    expect(exam).toHaveLength(expectedTotal);
    const order = exam.map((q) => q.category);
    const expectedOrder = CATEGORIES.flatMap((c) => Array<string>(c.examCount).fill(c.id));
    expect(order).toEqual(expectedOrder);
    expect(new Set(exam.map((q) => q.id)).size).toBe(exam.length);
  });

  it("同じシードなら同じ出題になる", () => {
    const a = buildExam(QUESTIONS, seededRng(7)).map((q) => q.id);
    const b = buildExam(QUESTIONS, seededRng(7)).map((q) => q.id);
    expect(a).toEqual(b);
  });

  it("バンクが不足している分野はある分だけ出す", () => {
    const small = QUESTIONS.filter((q) => q.category === "chiri").slice(0, 3);
    expect(buildExam(small, rng())).toHaveLength(3);
  });
});

describe("buildDrill", () => {
  it("分野を絞って指定数だけ出す", () => {
    const drill = buildDrill(QUESTIONS, "gyoho", 10, rng());
    expect(drill).toHaveLength(10);
    expect(drill.every((q) => q.category === "gyoho")).toBe(true);
  });

  it("null なら全分野から出す", () => {
    const drill = buildDrill(QUESTIONS, null, 1000, rng());
    expect(drill).toHaveLength(QUESTIONS.length);
  });
});

describe("scoreExam", () => {
  const pick = (category: Question["category"], n: number) => QUESTIONS.filter((q) => q.category === category).slice(0, n);

  it("科目ごとに配点を集計し、全科目 60% 以上で合格", () => {
    const gyoho = pick("gyoho", 5);
    const yakkan = pick("yakkan", 5);
    const unchin = pick("unchin", 2);
    const chiri = pick("chiri", 4);
    const qs = [...gyoho, ...yakkan, ...unchin, ...chiri];
    // 旅行業法 3/5, 約款 3/5, 実務: 運賃 2/2 (8点) + 地理 1/4 (2点) = 10/16
    const answers = Object.fromEntries([
      ...gyoho.map((q, i) => [q.id, i < 3 ? q.answer : ((q.answer + 1) % 4)]),
      ...yakkan.map((q, i) => [q.id, i < 3 ? q.answer : ((q.answer + 1) % 4)]),
      ...unchin.map((q) => [q.id, q.answer]),
      ...chiri.map((q, i) => [q.id, i < 1 ? q.answer : ((q.answer + 1) % 4)]),
    ]) as Record<string, 0 | 1 | 2 | 3>;

    const score = scoreExam(qs, answers);
    expect(score.correct).toBe(9);
    expect(score.total).toBe(16);
    const bySubject = Object.fromEntries(score.subjects.map((s) => [s.subject, s]));
    expect(bySubject.gyoho?.points).toBe(12);
    expect(bySubject.gyoho?.passed).toBe(true);
    expect(bySubject.jitsumu?.points).toBe(10);
    expect(bySubject.jitsumu?.maxPoints).toBe(16);
    expect(bySubject.jitsumu?.passed).toBe(true);
    expect(score.passed).toBe(true);
  });

  it("1科目でも 60% 未満なら不合格", () => {
    const gyoho = pick("gyoho", 5);
    const yakkan = pick("yakkan", 5);
    const answers = Object.fromEntries([
      ...gyoho.map((q) => [q.id, q.answer]),
      ...yakkan.map((q, i) => [q.id, i < 2 ? q.answer : ((q.answer + 1) % 4)]),
    ]) as Record<string, 0 | 1 | 2 | 3>;
    const score = scoreExam([...gyoho, ...yakkan], answers);
    expect(score.subjects.find((s) => s.subject === "yakkan")?.passed).toBe(false);
    expect(score.passed).toBe(false);
  });

  it("未回答は不正解として扱う", () => {
    const qs = pick("gyoho", 2);
    const score = scoreExam(qs, {});
    expect(score.correct).toBe(0);
    expect(score.total).toBe(2);
  });
});
