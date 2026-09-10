import type { Question } from "../../types";
import { chiri } from "./chiri";
import { gyoho } from "./gyoho";
import { unchin } from "./unchin";
import { yakkan } from "./yakkan";

/** 全問題バンク。分野ごとのファイルを追加したらここに連結する */
export const QUESTIONS: readonly Question[] = [...gyoho, ...yakkan, ...unchin, ...chiri];
