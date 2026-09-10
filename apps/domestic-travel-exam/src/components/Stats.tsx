import { useState } from "react";
import { categoryStats } from "../lib/storage";
import type { Progress } from "../lib/storage";
import { MODE_LABEL } from "../session";
import { CATEGORIES } from "../types";
import type { Question } from "../types";

interface Props {
  readonly bank: readonly Question[];
  readonly progress: Progress;
  readonly onReset: () => void;
}

function formatDate(ms: number): string {
  return new Date(ms).toLocaleString("ja-JP", { month: "numeric", day: "numeric", hour: "2-digit", minute: "2-digit" });
}

export function Stats({ bank, progress, onReset }: Props) {
  const [confirming, setConfirming] = useState(false);

  return (
    <div className="stack">
      <section className="card">
        <h1>分野別の成績</h1>
        <table className="subject-table">
          <thead>
            <tr>
              <th>分野</th>
              <th>学習済</th>
              <th>回答数</th>
              <th>正答率</th>
            </tr>
          </thead>
          <tbody>
            {CATEGORIES.map((meta) => {
              const s = categoryStats(bank, progress, meta.id);
              const rate = s.attempts === 0 ? "—" : `${Math.round((s.correct / s.attempts) * 100)}%`;
              return (
                <tr key={meta.id}>
                  <td>{meta.short}</td>
                  <td>
                    {s.answered} / {s.total}
                  </td>
                  <td>{s.attempts}</td>
                  <td>{rate}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </section>

      <section className="card">
        <h2>履歴</h2>
        {progress.history.length === 0 ? (
          <p className="muted">まだ記録がありません。</p>
        ) : (
          <ul className="history">
            {progress.history.map((h) => (
              <li key={h.at}>
                <span className="muted">{formatDate(h.at)}</span>
                <span>
                  {MODE_LABEL[h.mode]}
                  {h.category !== null && `（${CATEGORIES.find((c) => c.id === h.category)?.short ?? ""}）`}
                </span>
                <span>
                  {h.correct} / {h.total}
                </span>
                <span className={h.passed === null ? "" : h.passed ? "pass-text" : "fail-text"}>{h.passed === null ? "" : h.passed ? "合格" : "不合格"}</span>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="card">
        <h2>学習記録のリセット</h2>
        <p className="muted">このブラウザに保存されている回答履歴と成績をすべて削除します。</p>
        {confirming ? (
          <div className="row">
            <button type="button" className="danger" onClick={() => { onReset(); setConfirming(false); }}>
              本当に削除する
            </button>
            <button type="button" className="secondary" onClick={() => setConfirming(false)}>
              やめる
            </button>
          </div>
        ) : (
          <button type="button" className="secondary" onClick={() => setConfirming(true)}>
            リセット…
          </button>
        )}
      </section>
    </div>
  );
}
