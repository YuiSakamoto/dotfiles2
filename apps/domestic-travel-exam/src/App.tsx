import { useCallback, useEffect, useMemo, useState } from "react";
import { Home } from "./components/Home";
import { Quiz } from "./components/Quiz";
import { ResultView } from "./components/ResultView";
import { Stats } from "./components/Stats";
import { QUESTIONS } from "./data/questions";
import { buildDrill, buildExam, isCorrect, scoreExam } from "./lib/exam";
import type { Answers, ExamScore } from "./lib/exam";
import { appendHistory, clearProgress, loadProgress, recordAnswer, saveProgress, weakQuestions } from "./lib/storage";
import type { Progress } from "./lib/storage";
import type { Session } from "./session";
import type { CategoryId, ChoiceIndex } from "./types";

type Screen =
  | { kind: "home" }
  | { kind: "quiz"; session: Session }
  | { kind: "result"; session: Session; answers: Answers; score: ExamScore }
  | { kind: "stats" };

export function App() {
  const [progress, setProgress] = useState<Progress>(() => loadProgress());
  const [screen, setScreen] = useState<Screen>({ kind: "home" });
  const [saveError, setSaveError] = useState<string | null>(null);

  // 進捗が変わるたびに保存。失敗しても学習は続けられるよう画面上で知らせるだけにする
  useEffect(() => {
    const r = saveProgress(progress);
    setSaveError(r.ok ? null : r.error);
  }, [progress]);

  const weak = useMemo(() => weakQuestions(QUESTIONS, progress), [progress]);

  const startExam = useCallback(() => {
    setScreen({ kind: "quiz", session: { mode: "exam", category: null, questions: buildExam(QUESTIONS), startedAt: Date.now() } });
  }, []);

  const startDrill = useCallback((category: CategoryId | null, count: number) => {
    const questions = buildDrill(QUESTIONS, category, count);
    if (questions.length === 0) return;
    setScreen({ kind: "quiz", session: { mode: "drill", category, questions, startedAt: Date.now() } });
  }, []);

  const startReview = useCallback(() => {
    const questions = buildDrill(weak, null, weak.length);
    if (questions.length === 0) return;
    setScreen({ kind: "quiz", session: { mode: "review", category: null, questions, startedAt: Date.now() } });
  }, [weak]);

  // ドリル・復習では1問ごとに記録する（途中でやめても学習履歴が残る）
  const handleAnswered = useCallback((questionId: string, choice: ChoiceIndex) => {
    const question = QUESTIONS.find((q) => q.id === questionId);
    if (question === undefined) return;
    setProgress((p) => recordAnswer(p, questionId, isCorrect(question, choice), Date.now()));
  }, []);

  const handleFinish = useCallback((session: Session, answers: Answers) => {
    const score = scoreExam(session.questions, answers);
    setProgress((p) => {
      // 模試は採点時にまとめて記録する（試験中は正誤を見せないため）
      const withRecords =
        session.mode === "exam"
          ? session.questions.reduce((acc, q) => recordAnswer(acc, q.id, isCorrect(q, answers[q.id]), Date.now()), p)
          : p;
      return appendHistory(withRecords, {
        at: Date.now(),
        mode: session.mode,
        category: session.category,
        correct: score.correct,
        total: score.total,
        score,
        graded: session.mode === "exam",
      });
    });
    setScreen({ kind: "result", session, answers, score });
  }, []);

  const goHome = useCallback(() => setScreen({ kind: "home" }), []);

  const handleReset = useCallback(() => {
    clearProgress();
    setProgress({ records: {}, history: [] });
  }, []);

  return (
    <div className="app">
      <header className="app-header">
        <button type="button" className="brand" onClick={goHome}>
          国内旅行業務取扱管理者 試験対策
        </button>
        <nav>
          <button type="button" className="link" onClick={goHome} aria-current={screen.kind === "home" ? "page" : undefined}>
            ホーム
          </button>
          <button type="button" className="link" onClick={() => setScreen({ kind: "stats" })} aria-current={screen.kind === "stats" ? "page" : undefined}>
            成績
          </button>
        </nav>
      </header>

      {saveError !== null && <p className="notice">進捗を保存できませんでした（{saveError}）。このブラウザでは学習記録が残りません。</p>}

      <main className="app-main">
        {screen.kind === "home" && (
          <Home bank={QUESTIONS} progress={progress} weakCount={weak.length} onStartExam={startExam} onStartDrill={startDrill} onStartReview={startReview} />
        )}
        {screen.kind === "quiz" && (
          <Quiz key={screen.session.startedAt} session={screen.session} onAnswered={handleAnswered} onFinish={(answers) => handleFinish(screen.session, answers)} onQuit={goHome} />
        )}
        {screen.kind === "result" && (
          <ResultView
            session={screen.session}
            answers={screen.answers}
            score={screen.score}
            onHome={goHome}
            onRetryWrong={() => {
              const wrong = screen.session.questions.filter((q) => !isCorrect(q, screen.answers[q.id]));
              if (wrong.length === 0) return;
              setScreen({ kind: "quiz", session: { mode: "review", category: null, questions: buildDrill(wrong, null, wrong.length), startedAt: Date.now() } });
            }}
          />
        )}
        {screen.kind === "stats" && <Stats bank={QUESTIONS} progress={progress} onReset={handleReset} />}
      </main>

      <footer className="app-footer">
        <p>収録問題は学習用に作成したオリジナル問題です。法令・約款・運賃は改正されることがあるため、最新の公式資料もあわせて確認してください。</p>
      </footer>
    </div>
  );
}
