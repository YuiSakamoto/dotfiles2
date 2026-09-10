/** 乱数源。テストで固定できるよう関数として受け渡す */
export type Rng = () => number;

/** Fisher–Yates。元配列は変更しない */
export function shuffle<T>(items: readonly T[], rng: Rng = Math.random): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(rng() * (i + 1));
    const a = copy[i] as T;
    copy[i] = copy[j] as T;
    copy[j] = a;
  }
  return copy;
}

/** 決定的な疑似乱数（mulberry32）。シード付き模試の再現用 */
export function seededRng(seed: number): Rng {
  const state = { s: seed >>> 0 };
  return () => {
    state.s = (state.s + 0x6d2b79f5) >>> 0;
    const t0 = Math.imul(state.s ^ (state.s >>> 15), 1 | state.s);
    const t1 = (t0 + Math.imul(t0 ^ (t0 >>> 7), 61 | t0)) ^ t0;
    return ((t1 ^ (t1 >>> 14)) >>> 0) / 4294967296;
  };
}
