import Foundation

/// Entertainment-only estimate derived from an approximate pupil-to-iris ratio.
struct ScanResult: Equatable {
    /// Approximate pupil diameter relative to iris diameter (0...1). Typical resting ~0.2–0.4.
    let pupilIrisRatio: Double
    /// Playful entertainment score 0–100. Not a real alcohol measurement.
    let drunkProbability: Int
    /// Human-readable label for the fun score band.
    let funLabel: String
    let capturedAt: Date

    static func from(pupilIrisRatio: Double) -> ScanResult {
        let clamped = min(max(pupilIrisRatio, 0.05), 0.85)
        // Map ratio into a playful curve. Dilated pupils (higher ratio) → higher fun score.
        // Baseline around 0.28; entertainment-only heuristic.
        let normalized = (clamped - 0.18) / 0.45
        let curved = min(max(normalized, 0), 1)
        let scored = Int((pow(curved, 0.85) * 100).rounded())
        let label: String
        switch scored {
        case 0..<15: label = "Stone sober vibes"
        case 15..<35: label = "Barely buzzed energy"
        case 35..<55: label = "Tipsy territory (maybe)"
        case 55..<75: label = "Party mode suspected"
        case 75..<90: label = "Full send energy"
        default: label = "Legendary dilation"
        }
        return ScanResult(
            pupilIrisRatio: clamped,
            drunkProbability: scored,
            funLabel: label,
            capturedAt: Date()
        )
    }
}
