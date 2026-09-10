/** 出題分野。実試験の科目構成に合わせる */
export type CategoryId = "gyoho" | "yakkan" | "unchin" | "chiri";

/** 合否判定の単位となる科目。国内旅行実務は運賃・料金と観光地理を合算して1科目 */
export type SubjectId = "gyoho" | "yakkan" | "jitsumu";

export type ChoiceIndex = 0 | 1 | 2 | 3;

export interface Question {
  readonly id: string;
  readonly category: CategoryId;
  readonly question: string;
  readonly choices: readonly [string, string, string, string];
  readonly answer: ChoiceIndex;
  readonly explanation: string;
}

export interface CategoryMeta {
  readonly id: CategoryId;
  readonly subject: SubjectId;
  readonly label: string;
  readonly short: string;
  /** 模擬試験での出題数（実試験の配分に合わせる） */
  readonly examCount: number;
  /** 1問あたりの配点 */
  readonly points: number;
}

export interface SubjectMeta {
  readonly id: SubjectId;
  readonly label: string;
  readonly categories: readonly CategoryId[];
}

export const CATEGORIES: readonly CategoryMeta[] = [
  { id: "gyoho", subject: "gyoho", label: "旅行業法及びこれに基づく命令", short: "旅行業法", examCount: 25, points: 4 },
  { id: "yakkan", subject: "yakkan", label: "旅行業約款・運送約款・宿泊約款", short: "約款", examCount: 25, points: 4 },
  { id: "unchin", subject: "jitsumu", label: "国内旅行実務（運賃・料金）", short: "運賃・料金", examCount: 12, points: 4 },
  { id: "chiri", subject: "jitsumu", label: "国内旅行実務（観光地理）", short: "観光地理", examCount: 26, points: 2 },
];

export const SUBJECTS: readonly SubjectMeta[] = [
  { id: "gyoho", label: "旅行業法", categories: ["gyoho"] },
  { id: "yakkan", label: "約款", categories: ["yakkan"] },
  { id: "jitsumu", label: "国内旅行実務", categories: ["unchin", "chiri"] },
];

/** 各科目 60% 以上で合格 */
export const PASS_RATIO = 0.6;

export function categoryMeta(id: CategoryId): CategoryMeta {
  const meta = CATEGORIES.find((c) => c.id === id);
  if (meta === undefined) {
    // CATEGORIES は CategoryId を網羅しているため到達しない
    return CATEGORIES[0] as CategoryMeta;
  }
  return meta;
}

export type Result<T, E = string> = { ok: true; value: T } | { ok: false; error: E };
