import { useState } from "react";
import { categoryStats } from "../lib/storage";
import type { Progress } from "../lib/storage";
import { CATEGORIES } from "../types";
import type { CategoryId, Question } from "../types";

interface Props {
  readonly bank: readonly Question[];
  readonly progress: Progress;
  readonly weakCount: number;
  readonly onStartExam: () => void;
  readonly onStartDrill: (category: CategoryId | null, count: number) => void;
  readonly onStartReview: () => void;
}

const DRILL_COUNTS = [10, 20, 0] as const;

export function Home({ bank, progress, weakCount, onStartExam, onStartDrill, onStartReview }: Props) {
  const [count, setCount] = useState<number>(10);
  const examTotal = CATEGORIES.reduce((s, c) => s + c.examCount, 0);

  return (
    <div className="stack">
      <section className="card hero">
        <h1>模擬試験</h1>
        <p>
          実試験と同じ配分（旅行業法25問・約款25問・運賃12問・観光地理26問＝{examTotal}問）で出題します。採点は終了後にまとめて行い、各科目60%以上で合格判定です。
        </p>
        <button type="button" className="primary" onClick={onStartExam}>
          模擬試験を始める
        </button>
      </section>

      <section className="card">
        <div className="row between">
          <h2>分野別ドリル</h2>
          <div className="segmented" role="radiogroup" aria-label="出題数">
            {DRILL_COUNTS.map((n) => (
              <button key={n} type="button" role="radio" aria-checked={count === n} className={count === n ? "on" : ""} onClick={() => setCount(n)}>
                {n === 0 ? "全問" : `${n}問`}
              </button>
            ))}
          </div>
        </div>
        <p className="muted">1問ごとに正誤と解説を表示します。</p>
        <ul className="category-list">
          {CATEGORIES.map((meta) => {
            const s = categoryStats(bank, progress, meta.id);
            const rate = s.attempts === 0 ? null : Math.round((s.correct / s.attempts) * 100);
            return (
              <li key={meta.id}>
                <button type="button" className="category" onClick={() => onStartDrill(meta.id, count === 0 ? s.total : count)}>
                  <span className="category-label">
                    <strong>{meta.short}</strong>
                    <small>{meta.label}</small>
                  </span>
                  <span className="category-stat">
                    <span>
                      {s.answered}/{s.total}問 学習済
                    </span>
                    <span>{rate === null ? "正答率 —" : `正答率 ${rate}%`}</span>
                  </span>
                </button>
              </li>
            );
          })}
          <li>
            <button type="button" className="category" onClick={() => onStartDrill(null, count === 0 ? bank.length : count)}>
              <span className="category-label">
                <strong>全分野ミックス</strong>
                <small>全{bank.length}問からランダム</small>
              </span>
            </button>
          </li>
        </ul>
      </section>

      <section className="card">
        <div className="row between">
          <h2>弱点復習</h2>
          <span className="badge">{weakCount}問</span>
        </div>
        <p className="muted">直近で間違えた問題と、正答率50%未満の問題をまとめて出題します。</p>
        <button type="button" className="secondary" onClick={onStartReview} disabled={weakCount === 0}>
          {weakCount === 0 ? "弱点はありません" : "弱点を復習する"}
        </button>
      </section>
    </div>
  );
}
