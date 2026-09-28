# Eye Dilation Drunk

Entertainment app that uses the **camera + flashlight/torch** to estimate pupil dilation **on-device**, then shows a playful **0–100% “drunk probability.”**

**This is not a real alcohol, medical, legal, or safety test.**

Primary path: **Expo Go** on a physical iPhone (or Android).  
Legacy native SwiftUI / AVFoundation project: [`native-ios/`](./native-ios/).

---

## Run in Expo Go (recommended)

1. Install [Expo Go](https://expo.dev/go) on your iPhone.
2. Clone this repo and install deps:

```bash
git clone https://github.com/joshuaofisrael/eye-dilation-drunk.git
cd eye-dilation-drunk
npm install
npx expo start --tunnel
```

3. Scan the QR code shown in the terminal / browser with the iPhone Camera app (or Expo Go).
4. Acknowledge **“I understand — for entertainment only”**, allow camera, then run a scan.

Torch / flashlight requires a **real device** (simulators usually have no torch).

Same-Wi‑Fi LAN mode (if tunnel is unnecessary):

```bash
npx expo start
```

---

## Disclaimer (summary)

Before measuring, and again on results, the app states clearly:

1. **For fun and entertainment only**
2. **Does NOT authorize drinking then driving**
3. **A breathalyzer must be used for any real alcohol check**
4. **Not medical, legal, or safety advice**
5. **Privacy: on-device only** — eye images are never uploaded

The first screen requires tapping **“I understand — for entertainment only”** before the camera is used.

---

## How the entertainment estimate works

1. Back camera preview with an eye alignment reticle.
2. Torch turns on; a still frame is captured via `expo-camera` (`CameraView` + `enableTorch` + `takePictureAsync`).
3. On-device JS heuristic (center crop + darkness / contrast radial analysis with `jpeg-js`) estimates a **pupil-to-iris ratio**.
4. That approximate ratio is mapped to a fun **0–100%** score with clear “entertainment” labeling.

Lighting, eye color, contacts, medication, and many other factors affect pupils. **None of this equals intoxication measurement.**

---

## Project layout

```
├── App.tsx                 # Screen flow (disclaimer → home → scan → result)
├── app.json                # Expo config + camera permission plugin
├── package.json
├── index.ts
├── src/
│   ├── lib/
│   │   ├── scanResult.ts   # Fun 0–100% mapping
│   │   └── pupilAnalyzer.ts# On-device JPEG heuristic
│   └── screens/
│       ├── DisclaimerScreen.tsx
│       ├── HomeScreen.tsx
│       ├── ScanScreen.tsx  # CameraView + torch
│       └── ResultScreen.tsx
├── assets/
├── native-ios/             # Original SwiftUI / Xcode project
└── .github/workflows/ci.yml
```

Expo Go compatible only — no custom native modules / no Vision Camera frame processors.

---

## Scripts

| Command | Purpose |
|--------|---------|
| `npm start` / `npx expo start` | Dev server (LAN) |
| `npm run tunnel` / `npx expo start --tunnel` | Dev server with tunnel (QR from anywhere) |
| `npm run ios` / `npm run android` | Open in simulator / emulator when available |

---

## CI

A free GitHub Actions workflow template lives at [`docs/github-actions-ci.yml`](./docs/github-actions-ci.yml). Copy it to `.github/workflows/ci.yml` on GitHub (or with a token that has the `workflow` scope) to enable structure checks + `npm ci` + typecheck. Full camera/torch verification is on a physical device with Expo Go.

---

## Native iOS (optional)

See [`native-ios/README.md`](./native-ios/README.md) for the original Xcode / SwiftUI app. Prefer Expo Go unless you specifically need the native Vision landmark path.

---

## License / intent

Novelty / entertainment project. Do not use for driving decisions, workplace testing, medical assessment, or any safety-critical purpose.
