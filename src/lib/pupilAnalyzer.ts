import * as jpeg from 'jpeg-js';
import type { ScanResult } from './scanResult';
import { scanResultFromRatio } from './scanResult';

/**
 * On-device entertainment heuristic: estimates pupil vs iris size from a JPEG
 * still (base64). Center-crop + radial dark-blob analysis in pure JS.
 * Approximate only — not medical or forensic analysis.
 */
export function analyzeBase64Jpeg(base64: string): ScanResult {
  const raw = base64.includes(',') ? base64.split(',')[1] : base64;
  const binary = atob(raw);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  const decoded = jpeg.decode(bytes, { useTArray: true, formatAsRGBA: true });
  const { width, height, data } = decoded;
  if (!width || !height || !data) {
    throw new Error('Image processing failed. Please retry the entertainment scan.');
  }

  // Center-ish square crop (slightly upper-center for eye-level holds)
  const side = Math.floor(Math.min(width, height) * 0.45);
  const originX = Math.floor((width - side) / 2);
  const originY = Math.floor(height * 0.35);
  const cropW = Math.min(side, width - originX);
  const cropH = Math.min(side, height - originY);

  const crop = new Uint8ClampedArray(cropW * cropH);
  for (let y = 0; y < cropH; y++) {
    for (let x = 0; x < cropW; x++) {
      const src = ((originY + y) * width + (originX + x)) * 4;
      const r = data[src];
      const g = data[src + 1];
      const b = data[src + 2];
      // luminance, slight contrast boost for entertainment heuristic
      const L = 0.299 * r + 0.587 * g + 0.114 * b;
      crop[y * cropW + x] = Math.min(255, Math.max(0, (L - 128) * 1.15 + 128));
    }
  }

  const ratio = pupilRatioFromLumaCrop(crop, cropW, cropH);
  return scanResultFromRatio(ratio);
}

function pupilRatioFromLumaCrop(
  luma: Uint8ClampedArray,
  w: number,
  h: number
): number {
  const luminance = (x: number, y: number) => luma[y * w + x];

  const cx0 = Math.floor(w / 2);
  const cy0 = Math.floor(h / 2);
  const searchR = Math.floor(Math.min(w, h) / 4);
  let darkest = 255;
  let pupilCX = cx0;
  let pupilCY = cy0;

  for (let y = Math.max(0, cy0 - searchR); y < Math.min(h, cy0 + searchR); y++) {
    for (let x = Math.max(0, cx0 - searchR); x < Math.min(w, cx0 + searchR); x++) {
      const L = luminance(x, y);
      if (L < darkest) {
        darkest = L;
        pupilCX = x;
        pupilCY = y;
      }
    }
  }

  const pupilThreshold = darkest + 28;
  const maxR = (Math.min(w, h) / 2) * 0.92;
  let pupilRadius = 2;
  let irisRadius = maxR * 0.55;

  let r = 2;
  while (r < maxR) {
    const avg = averageRingLuminance(luminance, pupilCX, pupilCY, r, 36, w, h);
    if (avg > pupilThreshold) {
      pupilRadius = Math.max(2, r - 1);
      break;
    }
    r += 1;
  }

  const irisBrightFloor = pupilThreshold + 40;
  let foundIris = false;
  r = pupilRadius + 2;
  while (r < maxR) {
    const avg = averageRingLuminance(luminance, pupilCX, pupilCY, r, 48, w, h);
    if (avg > irisBrightFloor + 50) {
      irisRadius = r;
      foundIris = true;
      break;
    }
    r += 1.5;
  }
  if (!foundIris) {
    irisRadius = Math.min(maxR, pupilRadius * 2.8);
  }
  irisRadius = Math.max(irisRadius, pupilRadius * 1.6);

  const ratio = pupilRadius / irisRadius;
  return Math.min(Math.max(ratio, 0.08), 0.75);
}

function averageRingLuminance(
  luminance: (x: number, y: number) => number,
  cx: number,
  cy: number,
  radius: number,
  samples: number,
  w: number,
  h: number
): number {
  let sum = 0;
  let count = 0;
  for (let i = 0; i < samples; i++) {
    const angle = (i / samples) * 2 * Math.PI;
    const x = Math.round(cx + Math.cos(angle) * radius);
    const y = Math.round(cy + Math.sin(angle) * radius);
    if (x >= 0 && x < w && y >= 0 && y < h) {
      sum += luminance(x, y);
      count += 1;
    }
  }
  return count > 0 ? sum / count : 255;
}
