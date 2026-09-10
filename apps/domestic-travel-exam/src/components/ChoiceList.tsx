import type { ChoiceIndex, Question } from "../types";

interface Props {
  readonly question: Question;
  readonly selected: ChoiceIndex | undefined;
  /** true なら正誤を色分けして表示する */
  readonly revealed: boolean;
  readonly onSelect?: (choice: ChoiceIndex) => void;
}

const LABELS = ["1", "2", "3", "4"] as const;

export function ChoiceList({ question, selected, revealed, onSelect }: Props) {
  return (
    <ol className="choices">
      {question.choices.map((text, i) => {
        const idx = i as ChoiceIndex;
        const state = revealed ? (idx === question.answer ? "correct" : idx === selected ? "wrong" : "") : idx === selected ? "selected" : "";
        return (
          <li key={idx}>
            <button type="button" className={`choice ${state}`} onClick={() => onSelect?.(idx)} disabled={onSelect === undefined || (revealed && selected !== undefined)} aria-pressed={idx === selected}>
              <span className="choice-key">{LABELS[idx]}</span>
              <span>{text}</span>
            </button>
          </li>
        );
      })}
    </ol>
  );
}
