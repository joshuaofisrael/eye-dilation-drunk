import SwiftUI

struct ScanView: View {
    @ObservedObject var camera: CameraManager
    let onResult: (ScanResult) -> Void
    let onCancel: () -> Void

    @State private var isScanning = false
    @State private var progress: Double = 0
    @State private var statusText = "Align one eye in the circle"
    @State private var scanError: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if camera.authorizationStatus == .authorized {
                CameraPreviewView(session: camera.session)
                    .ignoresSafeArea()
            } else {
                permissionPlaceholder
            }

            // Dark vignette + eye guide
            RadialGradient(
                colors: [.clear, .black.opacity(0.55)],
                center: .center,
                startRadius: 80,
                endRadius: 420
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                topBar
                Spacer()
                guideRing
                Spacer()
                bottomPanel
            }
            .padding()
        }
        .alert("Scan issue", isPresented: Binding(
            get: { scanError != nil },
            set: { if !$0 { scanError = nil } }
        )) {
            Button("OK", role: .cancel) { scanError = nil }
        } message: {
            Text(scanError ?? "")
        }
        .onAppear {
            camera.checkAuthorization()
        }
        .onDisappear {
            camera.setTorch(false)
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: onCancel) {
                Label("Back", systemImage: "chevron.left")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            Spacer()
            Text("Entertainment scan")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.orange.opacity(0.9)))
        }
    }

    private var guideRing: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.85), lineWidth: 3)
                .frame(width: 220, height: 220)
            Circle()
                .strokeBorder(Color.orange.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .frame(width: 140, height: 140)
            if isScanning {
                ProgressView(value: progress)
                    .progressViewStyle(.circular)
                    .tint(.orange)
                    .scaleEffect(1.4)
            }
        }
    }

    private var bottomPanel: some View {
        VStack(spacing: 14) {
            Text(statusText)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text("On-device only · nothing uploaded · not a real alcohol test")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if camera.authorizationStatus == .authorized {
                Button(action: startScan) {
                    HStack {
                        Image(systemName: "flashlight.on.fill")
                        Text(isScanning ? "Scanning…" : "Start entertainment scan")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(isScanning)
            }

            if !camera.torchAvailable && camera.authorizationStatus == .authorized {
                Text("Torch not available on this device — results may be less reliable.")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private var permissionPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Camera access needed")
                .font(.headline)
            Text("Enable camera in Settings to run the entertainment pupil scan. Processing stays on this device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if camera.authorizationStatus == .denied || camera.authorizationStatus == .restricted {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func startScan() {
        guard !isScanning else { return }
        isScanning = true
        progress = 0
        statusText = "Warming torch…"
        scanError = nil

        Task {
            camera.setTorch(true)
            // Progress animation while torch stabilizes and we capture
            for step in 1...8 {
                try? await Task.sleep(nanoseconds: 180_000_000)
                await MainActor.run {
                    progress = Double(step) / 10.0
                    if step == 3 { statusText = "Hold steady — looking at pupil…" }
                    if step == 6 { statusText = "Capturing frame…" }
                }
            }

            do {
                let image = try await camera.capturePhoto()
                await MainActor.run {
                    progress = 0.9
                    statusText = "Estimating dilation (entertainment)…"
                }
                let ratio = try await PupilAnalyzer.estimatePupilIrisRatio(from: image)
                let result = ScanResult.from(pupilIrisRatio: ratio)
                await MainActor.run {
                    progress = 1.0
                    camera.setTorch(false)
                    isScanning = false
                    onResult(result)
                }
            } catch {
                await MainActor.run {
                    camera.setTorch(false)
                    isScanning = false
                    progress = 0
                    statusText = "Align one eye in the circle"
                    scanError = error.localizedDescription
                }
            }
        }
    }
}
