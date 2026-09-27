import AVFoundation
import UIKit
import Combine

/// Manages rear camera preview, capture, and torch for on-device entertainment scans.
final class CameraManager: NSObject, ObservableObject {
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var isSessionRunning = false
    @Published var torchAvailable = false
    @Published var errorMessage: String?

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.joshuaisrael.EyeDilationDrunk.camera")
    private var device: AVCaptureDevice?
    private var photoContinuation: CheckedContinuation<CGImage, Error>?

    enum CameraError: LocalizedError {
        case noCamera
        case cannotAddInput
        case cannotAddOutput
        case captureFailed
        case notAuthorized

        var errorDescription: String? {
            switch self {
            case .noCamera: return "Rear camera not available."
            case .cannotAddInput: return "Could not configure camera input."
            case .cannotAddOutput: return "Could not configure camera output."
            case .captureFailed: return "Photo capture failed."
            case .notAuthorized: return "Camera access is required for the entertainment scan."
            }
        }
    }

    func checkAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async { self.authorizationStatus = status }
        switch status {
        case .authorized:
            configureSessionIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                }
                if granted {
                    self?.configureSessionIfNeeded()
                }
            }
        default:
            break
        }
    }

    private var isConfigured = false

    private func configureSessionIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self, !self.isConfigured else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.errorMessage = CameraError.noCamera.localizedDescription }
                return
            }
            self.device = camera

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                guard self.session.canAddInput(input) else {
                    throw CameraError.cannotAddInput
                }
                self.session.addInput(input)
            } catch {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }

            guard self.session.canAddOutput(self.photoOutput) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.errorMessage = CameraError.cannotAddOutput.localizedDescription }
                return
            }
            self.session.addOutput(self.photoOutput)
            if let connection = self.photoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
            }

            self.session.commitConfiguration()
            self.isConfigured = true

            let torchOK = camera.hasTorch && camera.isTorchAvailable
            DispatchQueue.main.async { self.torchAvailable = torchOK }
            self.startSession()
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async { self.isSessionRunning = true }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.setTorch(false)
            self.session.stopRunning()
            DispatchQueue.main.async { self.isSessionRunning = false }
        }
    }

    func setTorch(_ on: Bool) {
        sessionQueue.async { [weak self] in
            guard let device = self?.device, device.hasTorch else { return }
            do {
                try device.lockForConfiguration()
                if on {
                    try device.setTorchModeOn(level: 0.7)
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Torch unavailable: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Captures a still frame while torch is on. Returns a CGImage for on-device analysis.
    func capturePhoto() async throws -> CGImage {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CGImage, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: CameraError.captureFailed)
                    return
                }
                self.photoContinuation = continuation
                let settings = AVCapturePhotoSettings()
                settings.flashMode = .off // we control torch separately for steady light
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            photoContinuation?.resume(throwing: error)
            photoContinuation = nil
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            photoContinuation?.resume(throwing: CameraError.captureFailed)
            photoContinuation = nil
            return
        }
        photoContinuation?.resume(returning: cgImage)
        photoContinuation = nil
    }
}
