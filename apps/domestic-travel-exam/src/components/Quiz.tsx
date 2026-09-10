import { useCallback, useEffect, useMemo, useState } from "react";
import type { Answers } from "../lib/exam";
import { MODE_LABEL } from "../session";
import type { Session } from "../session";
import { categoryMeta } from "../types";
import type { ChoiceIndex } from "../types";
import { ChoiceList } from "./ChoiceList";

interface Props {
  readonly session: Session;
  readonly onAnswered: (questionId: string, choice: ChoiceIndex) => void;
  readonly onFinish: (answers: Answers) => void;
  readonly onQuit: () => void;
}

const KEY_TO_CHOICE: Record<string, ChoiceIndex> = { "1": 0, "2": 1, "3": 2, "4": 3 };

export function Quiz({ session, onAnswered, onFinish, onQuit }: Props) {
  const { questions, mode } = session;
  const instant = mode !== "exam";
  const [index, setIndex] = useState(0);
  const [answers, setAnswers] = useState<Answers>({});
  const [confirming, setConfirming] = useState(false);

  const question = questions[index];
  const total = questions.length;
  const answered = useMemo(() => questions.filter((q) => answers[q.id] !== undefined).length, [questions, answers]);
  const current = question === undefined ? undefined : answers[question.id];
  const isLast = index === total - 1;

  const select = useCallback(
    (choice: ChoiceIndex) => {
      if (question === undefined) return;
      // ドリルでは一度答えたら確定（解説を見てから答えを変えられないように）
      if (instant && current !== undefined) return;
      setAnswers((a) => ({ ...a, [question.id]: choice }));
      if (instant) onAnswered(question.id, choice);
    },
    [question, instant, current, onAnswered],
  );

  const next = useCallback(() => {
    if (isLast) {
      if (instant || answered === total) onFinish(answers);
      else setConfirming(true);
      return;
    }
    setIndex((i) => i + 1);
  }, [isLast, instant, answered, total, onFinish, answers]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLElement && ["INPUT", "TEXTAREA", "BUTTON"].includes(e.target.tagName) && e.key !== "Enter") return;
      const choice = KEY_TO_CHOICE[e.key];
      if (choice !== undefined) {
        select(choice);
        return;
      }
      if (e.key === "Enter" && (!instant || current !== undefined)) next();
      if (e.key === "ArrowLeft" && !instant) setIndex((i) => Math.max(0, i - 1));
      if (e.key === "ArrowRight" && !instant) setIndex((i) => Math.min(total - 1, i + 1));
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [select, next, instant, current, total]);

  if (question === undefined) {
    return (
      <div className="card">
        <p>出題できる問題がありません。</p>
        <button type="button" className="secondary" onClick={onQuit}>
          ホームへ戻る
        </button>
      </div>
    );
  }

  const meta = categoryMeta(question.category);
  const revealed = instant && current !== undefined;

  return (
    <div className="stack">
      <div className="quiz-bar">
        <span className="badge">{MODE_LABEL[mode]}</span>
        <span className="muted">
          {index + 1} / {total}
          {!instant && `　回答済 ${answered}`}
        </span>
        <button type="button" className="link" onClick={onQuit}>
          中断
        </button>
      </div>
      <progress className="progress" value={instant ? answered : index + 1} max={total} />

      <article className="card question" aria-live="polite">
        <p className="category-tag">{meta.label}</p>
        <h2 className="question-text">{question.question}</h2>
        <ChoiceList question={question} selected={current} revealed={revealed} onSelect={select} />
        {revealed && (
          <div className={`explanation ${current === question.answer ? "ok" : "ng"}`}>
            <strong>{current === question.answer ? "正解" : "不正解"}</strong>
            <p>{question.explanation}</p>
          </div>
        )}
      </article>

      <div className="row between">
        {instant ? (
          <span />
        ) : (
          <button type="button" className="secondary" onClick={() => setIndex((i) => Math.max(0, i - 1))} disabled={index === 0}>
            ← 前へ
          </button>
        )}
        <button type="button" className="primary" onClick={next} disabled={instant && current === undefined}>
          {isLast ? (instant ? "結果を見る" : "採点する") : "次へ →"}
        </button>
      </div>

      {!instant && (
        <nav className="grid-nav" aria-label="問題一覧">
          {questions.map((q, i) => (
            <button key={q.id} type="button" className={`${i === index ? "current" : ""} ${answers[q.id] !== undefined ? "done" : ""}`} onClick={() => setIndex(i)} aria-label={`問${i + 1}`}>
              {i + 1}
            </button>
          ))}
        </nav>
      )}

      {confirming && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="confirm-title">
          <div className="card modal">
            <h3 id="confirm-title">未回答の問題があります</h3>
            <p>
              {total - answered}問が未回答です。未回答は不正解として採点されます。このまま採点しますか？
            </p>
            <div className="row end">
              <button type="button" className="secondary" onClick={() => setConfirming(false)}>
                戻る
              </button>
              <button type="button" className="primary" onClick={() => onFinish(answers)}>
                採点する
              </button>
            </div>
          </div>
        </div>
      )}

      <p className="muted hint">キー操作: 1〜4 で選択、Enter で次へ{!instant && "、←→ で移動"}</p>
    </div>
  );
}
