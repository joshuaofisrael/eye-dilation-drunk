/** Entertainment-only estimate derived from an approximate pupil-to-iris ratio. */
export type ScanResult = {
  /** Approximate pupil diameter relative to iris diameter (0...1). */
  pupilIrisRatio: number;
  /** Playful entertainment score 0–100. Not a real alcohol measurement. */
  drunkProbability: number;
  /** Human-readable label for the fun score band. */
  funLabel: string;
  capturedAt: string;
};

export function scanResultFromRatio(pupilIrisRatio: number): ScanResult {
  const clamped = Math.min(Math.max(pupilIrisRatio, 0.05), 0.85);
  // Map ratio into a playful curve. Dilated pupils (higher ratio) → higher fun score.
  const normalized = (clamped - 0.18) / 0.45;
  const curved = Math.min(Math.max(normalized, 0), 1);
  const scored = Math.round(Math.pow(curved, 0.85) * 100);

  let funLabel: string;
  if (scored < 15) funLabel = 'Stone sober vibes';
  else if (scored < 35) funLabel = 'Barely buzzed energy';
  else if (scored < 55) funLabel = 'Tipsy territory (maybe)';
  else if (scored < 75) funLabel = 'Party mode suspected';
  else if (scored < 90) funLabel = 'Full send energy';
  else funLabel = 'Legendary dilation';

  return {
    pupilIrisRatio: clamped,
    drunkProbability: scored,
    funLabel,
    capturedAt: new Date().toISOString(),
  };
}
