import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Vision

/// On-device entertainment heuristic: estimates pupil vs iris size from a still frame.
/// Approximate only — not medical or forensic analysis.
enum PupilAnalyzer {
    enum AnalysisError: LocalizedError {
        case noFaceOrEye
        case processingFailed

        var errorDescription: String? {
            switch self {
            case .noFaceOrEye:
                return "Could not find an eye in the frame. Hold the phone close, look at the camera, and try again."
            case .processingFailed:
                return "Image processing failed. Please retry the entertainment scan."
            }
        }
    }

    static func estimatePupilIrisRatio(from cgImage: CGImage) async throws -> Double {
        // Prefer Vision face landmarks for eye region crop; fall back to center crop + brightness analysis.
        if let ratio = try? await estimateWithVision(cgImage: cgImage) {
            return ratio
        }
        return try estimateWithBrightnessHeuristic(cgImage: cgImage)
    }

    // MARK: - Vision landmarks path

    private static func estimateWithVision(cgImage: CGImage) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceLandmarksRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let face = (request.results as? [VNFaceObservation])?.first,
                      let landmarks = face.landmarks,
                      let leftEye = landmarks.leftEye ?? landmarks.rightEye else {
                    continuation.resume(throwing: AnalysisError.noFaceOrEye)
                    return
                }

                do {
                    let eyeCrop = try cropEyeRegion(cgImage: cgImage, face: face, eye: leftEye)
                    let ratio = try pupilRatioFromEyeCrop(eyeCrop)
                    continuation.resume(returning: ratio)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private static func cropEyeRegion(
        cgImage: CGImage,
        face: VNFaceObservation,
        eye: VNFaceLandmarkRegion2D
    ) throws -> CGImage {
        let points = eye.normalizedPoints
        guard !points.isEmpty else { throw AnalysisError.noFaceOrEye }

        let faceBox = face.boundingBox
        let imgW = CGFloat(cgImage.width)
        let imgH = CGFloat(cgImage.height)

        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0

        for p in points {
            let x = (faceBox.origin.x + p.x * faceBox.width) * imgW
            // Vision is bottom-left origin
            let y = (1 - (faceBox.origin.y + p.y * faceBox.height)) * imgH
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }

        let padX = (maxX - minX) * 0.6
        let padY = (maxY - minY) * 1.2
        var rect = CGRect(
            x: minX - padX,
            y: minY - padY,
            width: (maxX - minX) + padX * 2,
            height: (maxY - minY) + padY * 2
        )
        rect = rect.intersection(CGRect(x: 0, y: 0, width: imgW, height: imgH))
        guard rect.width > 8, rect.height > 8,
              let cropped = cgImage.cropping(to: rect.integral) else {
            throw AnalysisError.noFaceOrEye
        }
        return cropped
    }

    // MARK: - Brightness / radial dark-blob heuristic

    /// Finds a dark central blob (pupil) inside a brighter ring (iris) using luminance.
    private static func pupilRatioFromEyeCrop(_ eyeImage: CGImage) throws -> Double {
        let ciImage = CIImage(cgImage: eyeImage)
        let context = CIContext(options: [.useSoftwareRenderer: false])

        // Grayscale + slight blur to reduce noise
        let grayFilter = CIFilter.colorControls()
        grayFilter.inputImage = ciImage
        grayFilter.saturation = 0
        grayFilter.contrast = 1.15

        let blur = CIFilter.gaussianBlur()
        blur.inputImage = grayFilter.outputImage
        blur.radius = 1.5

        guard let processed = blur.outputImage,
              let rendered = context.createCGImage(processed, from: ciImage.extent) else {
            throw AnalysisError.processingFailed
        }

        let w = rendered.width
        let h = rendered.height
        guard let data = rendered.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else {
            throw AnalysisError.processingFailed
        }
        let bytesPerPixel = rendered.bitsPerPixel / 8
        let bytesPerRow = rendered.bytesPerRow

        func luminance(at x: Int, y: Int) -> Double {
            let o = y * bytesPerRow + x * bytesPerPixel
            // Prefer R channel after desaturation; average if RGBA
            let r = Double(ptr[o])
            let g = bytesPerPixel > 1 ? Double(ptr[o + 1]) : r
            let b = bytesPerPixel > 2 ? Double(ptr[o + 2]) : r
            return 0.299 * r + 0.587 * g + 0.114 * b
        }

        // Sample center region for darkest point (pupil center estimate)
        let cx0 = w / 2
        let cy0 = h / 2
        let searchR = min(w, h) / 4
        var darkest = 255.0
        var pupilCX = cx0
        var pupilCY = cy0
        for y in max(0, cy0 - searchR)..<min(h, cy0 + searchR) {
            for x in max(0, cx0 - searchR)..<min(w, cx0 + searchR) {
                let L = luminance(at: x, y: y)
                if L < darkest {
                    darkest = L
                    pupilCX = x
                    pupilCY = y
                }
            }
        }

        // Threshold: pixels near darkest are "pupil"
        let pupilThreshold = darkest + 28
        // Iris outer edge: first radius where average brightness rises sharply then plateaus
        let maxR = Double(min(w, h)) / 2.0 * 0.92
        var pupilRadius = 2.0
        var irisRadius = maxR * 0.55

        // Grow from center until brightness exceeds pupil threshold on average ring
        var r = 2.0
        while r < maxR {
            let avg = averageRingLuminance(
                luminance: luminance,
                cx: pupilCX, cy: pupilCY,
                radius: r, samples: 36,
                w: w, h: h
            )
            if avg > pupilThreshold {
                pupilRadius = max(2.0, r - 1)
                break
            }
            r += 1
        }

        // Continue outward: iris ends when we hit sclera (much brighter) or soft max
        let irisBrightFloor = pupilThreshold + 40
        var foundIris = false
        r = pupilRadius + 2
        while r < maxR {
            let avg = averageRingLuminance(
                luminance: luminance,
                cx: pupilCX, cy: pupilCY,
                radius: r, samples: 48,
                w: w, h: h
            )
            if avg > irisBrightFloor + 50 {
                irisRadius = r
                foundIris = true
                break
            }
            r += 1.5
        }
        if !foundIris {
            irisRadius = min(maxR, pupilRadius * 2.8)
        }
        irisRadius = max(irisRadius, pupilRadius * 1.6)

        let ratio = pupilRadius / irisRadius
        // Clamp to plausible entertainment range
        return min(max(ratio, 0.08), 0.75)
    }

    private static func averageRingLuminance(
        luminance: (Int, Int) -> Double,
        cx: Int, cy: Int,
        radius: Double,
        samples: Int,
        w: Int, h: Int
    ) -> Double {
        var sum = 0.0
        var count = 0
        for i in 0..<samples {
            let angle = Double(i) / Double(samples) * 2 * Double.pi
            let x = Int((Double(cx) + cos(angle) * radius).rounded())
            let y = Int((Double(cy) + sin(angle) * radius).rounded())
            if x >= 0, x < w, y >= 0, y < h {
                sum += luminance(x, y)
                count += 1
            }
        }
        return count > 0 ? sum / Double(count) : 255
    }

    /// Fallback when face landmarks fail: analyze a center square of the frame.
    private static func estimateWithBrightnessHeuristic(cgImage: CGImage) throws -> Double {
        let w = cgImage.width
        let h = cgImage.height
        let side = Int(Double(min(w, h)) * 0.45)
        let originX = (w - side) / 2
        let originY = Int(Double(h) * 0.35) // slightly upper-center for eye-level holds
        let rect = CGRect(x: originX, y: originY, width: side, height: side)
        guard let crop = cgImage.cropping(to: rect) else {
            throw AnalysisError.processingFailed
        }
        return try pupilRatioFromEyeCrop(crop)
    }
}
