import SwiftUI

struct ResultView: View {
    let result: ScanResult
    let onScanAgain: () -> Void
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Entertainment result")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.orange)
                    .padding(.top, 8)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 14)
                        .frame(width: 200, height: 200)
                    Circle()
                        .trim(from: 0, to: CGFloat(result.drunkProbability) / 100)
                        .stroke(
                            AngularGradient(
                                colors: [.green, .yellow, .orange, .red],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 200, height: 200)
                    VStack(spacing: 4) {
                        Text("\(result.drunkProbability)%")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                        Text("fun score")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)

                Text(result.funLabel)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                Text("Approx. pupil÷iris ratio: \(String(format: "%.2f", result.pupilIrisRatio))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Label("For fun and entertainment only", systemImage: "party.popper.fill")
                    Label("Does NOT authorize drinking then driving", systemImage: "car.fill")
                    Label("Use a breathalyzer for any real alcohol check", systemImage: "lungs.fill")
                    Label("Not medical, legal, or safety advice", systemImage: "cross.case.fill")
                    Label("Processed on-device — nothing uploaded", systemImage: "lock.shield.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.orange.opacity(0.15))
                )

                Text("This percentage is a playful mapping of an approximate pupil estimate. Lighting, eye color, contacts, and medication can change pupils — none of that equals intoxication measurement.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Button("Scan again", action: onScanAgain)
                        .buttonStyle(.bordered)
                    Button("Done", action: onDone)
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
                .padding(.top, 4)
            }
            .padding(24)
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
    }
}
