import SwiftUI

enum AppScreen: Equatable {
    case disclaimer
    case home
    case scan
    case result(ScanResult)
}

struct ContentView: View {
    @State private var screen: AppScreen = .disclaimer
    @StateObject private var camera = CameraManager()

    var body: some View {
        Group {
            switch screen {
            case .disclaimer:
                DisclaimerView {
                    withAnimation { screen = .home }
                }
            case .home:
                HomeView(
                    onStart: { withAnimation { screen = .scan } },
                    onShowDisclaimer: { withAnimation { screen = .disclaimer } }
                )
            case .scan:
                ScanView(
                    camera: camera,
                    onResult: { result in
                        withAnimation { screen = .result(result) }
                    },
                    onCancel: {
                        camera.setTorch(false)
                        withAnimation { screen = .home }
                    }
                )
            case .result(let result):
                ResultView(
                    result: result,
                    onScanAgain: { withAnimation { screen = .scan } },
                    onDone: { withAnimation { screen = .home } }
                )
            }
        }
    }
}

struct HomeView: View {
    let onStart: () -> Void
    let onShowDisclaimer: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "eye.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
            Text("Eye Dilation Drunk")
                .font(.largeTitle.bold())
            Text("A playful on-device pupil scan that invents a fun “drunk probability.” Not a real test.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 10) {
                Label("Rear camera + flashlight", systemImage: "camera.fill")
                Label("On-device only — nothing uploaded", systemImage: "iphone")
                Label("Entertainment estimate 0–100%", systemImage: "percent")
            }
            .font(.subheadline)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onStart) {
                Text("Start scan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal, 24)

            Button("Read disclaimer again", action: onShowDisclaimer)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
