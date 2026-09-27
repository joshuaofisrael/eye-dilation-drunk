# Eye Dilation Drunk

Entertainment iOS app that uses the **rear camera + flashlight** to estimate pupil dilation on-device, then shows a playful **0–100% “drunk probability.”**

**This is not a real alcohol, medical, legal, or safety test.**

Bundle ID: `com.joshuaisrael.EyeDilationDrunk`  
Platform: iOS 16+ · SwiftUI · AVFoundation · Vision / Core Image  
Dependencies: none (pure Apple frameworks)

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

## Open in Xcode and run on a physical iPhone

Torch / flashlight requires a **real device** (Simulator has no torch).

1. Copy or clone this project onto a Mac.
2. Open `EyeDilationDrunk.xcodeproj` in Xcode 15+ (or later).
3. Select the **EyeDilationDrunk** target → **Signing & Capabilities**.
4. Choose your **Team** (Apple ID / developer account). Xcode will create a provisioning profile.
5. Plug in an iPhone, trust the computer if prompted, select that device as the run destination.
6. Build & Run (⌘R).
7. On first launch, acknowledge the disclaimer, then allow **Camera** when prompted.
8. Hold the phone so one eye is centered in the guide ring, tap **Start entertainment scan**. The torch turns on during the scan.

If the app won’t launch on device: Settings → General → VPN & Device Management → trust your developer certificate.

---

## How the entertainment estimate works

1. Rear camera preview with an eye alignment guide.
2. Torch turns on; a still frame is captured.
3. On-device analysis (Vision face landmarks when possible, otherwise a center-crop brightness heuristic) estimates a **pupil-to-iris ratio**.
4. That approximate ratio is mapped to a fun **0–100%** score with clear “entertainment” labeling.

Lighting, eye color, contacts, medication, and many other factors affect pupils. **None of this equals intoxication measurement.**

---

## Project layout

```
EyeDilationDrunk/
├── EyeDilationDrunk.xcodeproj/     # Xcode project
├── EyeDilationDrunk/
│   ├── EyeDilationDrunkApp.swift   # @main entry
│   ├── ContentView.swift           # Navigation / screens
│   ├── Info.plist                  # NSCameraUsageDescription
│   ├── Assets.xcassets/
│   ├── Models/
│   │   └── ScanResult.swift        # Fun score mapping
│   ├── Services/
│   │   ├── CameraManager.swift     # AVFoundation + torch
│   │   └── PupilAnalyzer.swift     # On-device pupil heuristic
│   └── Views/
│       ├── DisclaimerView.swift
│       ├── ScanView.swift
│       ├── ResultView.swift
│       └── CameraPreviewView.swift
├── .github/workflows/ci.yml        # Structure validation (Linux)
└── README.md
```

---

## CI note

GitHub Actions on Linux **cannot** compile a full iOS app (no Xcode / iOS SDK). The included workflow validates project structure and required files. **Build and run on a Mac with Xcode** as described above.

---

## License / intent

Novelty / entertainment project. Do not use for driving decisions, workplace testing, medical assessment, or any safety-critical purpose.
