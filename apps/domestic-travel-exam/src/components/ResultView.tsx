import { isCorrect } from "../lib/exam";
import type { Answers, ExamScore } from "../lib/exam";
import { MODE_LABEL } from "../session";
import type { Session } from "../session";
import { categoryMeta } from "../types";
import { ChoiceList } from "./ChoiceList";

interface Props {
  readonly session: Session;
  readonly answers: Answers;
  readonly score: ExamScore;
  readonly onHome: () => void;
  readonly onRetryWrong: () => void;
}

export function ResultView({ session, answers, score, onHome, onRetryWrong }: Props) {
  const graded = session.mode === "exam";
  const wrongCount = score.total - score.correct;
  const percent = score.total === 0 ? 0 : Math.round((score.correct / score.total) * 100);

  return (
    <div className="stack">
      <section className={`card result-summary ${graded ? (score.passed ? "pass" : "fail") : ""}`}>
        <p className="badge">{MODE_LABEL[session.mode]}</p>
        {graded && <h1>{score.passed ? "合格ライン到達" : "不合格ライン"}</h1>}
        <p className="result-score">
          {score.correct} / {score.total} 問正解（{percent}%）
        </p>
        {graded && (
          <table className="subject-table">
            <thead>
              <tr>
                <th>科目</th>
                <th>得点</th>
                <th>正答</th>
                <th>判定</th>
              </tr>
            </thead>
            <tbody>
              {score.subjects.map((s) => (
                <tr key={s.subject} className={s.passed ? "" : "ng"}>
                  <td>{s.label}</td>
                  <td>
                    {s.points} / {s.maxPoints}点
                  </td>
                  <td>
                    {s.correct} / {s.total}
                  </td>
                  <td>{s.passed ? "○" : "×"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <div className="row">
          <button type="button" className="primary" onClick={onHome}>
            ホームへ
          </button>
          <button type="button" className="secondary" onClick={onRetryWrong} disabled={wrongCount === 0}>
            間違えた{wrongCount}問をやり直す
          </button>
        </div>
      </section>

      <section className="stack">
        <h2>解答と解説</h2>
        {session.questions.map((q, i) => {
          const selected = answers[q.id];
          const ok = isCorrect(q, selected);
          return (
            <article key={q.id} className={`card review ${ok ? "ok" : "ng"}`}>
              <p className="category-tag meta-line">
                <span>問{i + 1}</span>
                <span>{categoryMeta(q.category).short}</span>
                <strong>{selected === undefined ? "未回答" : ok ? "正解" : "不正解"}</strong>
              </p>
              <h3 className="question-text">{q.question}</h3>
              <ChoiceList question={q} selected={selected} revealed />
              <div className="explanation">
                <p>{q.explanation}</p>
              </div>
            </article>
          );
        })}
      </section>
    </div>
  );
}
