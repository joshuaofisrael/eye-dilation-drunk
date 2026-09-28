import SwiftUI

struct DisclaimerView: View {
    let onAcknowledge: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Before You Continue")
                            .font(.title2.bold())
                        Text("Required acknowledgment")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 4)

                disclaimerCard(
                    icon: "party.popper.fill",
                    title: "Entertainment only",
                    body: "Eye Dilation Drunk is a playful novelty app. Pupil estimates and “drunk probability” scores are for fun — they are not accurate alcohol measurements."
                )

                disclaimerCard(
                    icon: "car.fill",
                    title: "Never drink and drive",
                    body: "This app does NOT authorize drinking then driving. Never operate a vehicle after drinking alcohol, regardless of any score shown here."
                )

                disclaimerCard(
                    icon: "lungs.fill",
                    title: "Use a real breathalyzer",
                    body: "For any real alcohol check, you must use a properly calibrated breathalyzer or other approved testing method — not this app."
                )

                disclaimerCard(
                    icon: "cross.case.fill",
                    title: "Not medical, legal, or safety advice",
                    body: "Nothing in this app is medical, legal, or safety advice. Do not rely on it for health decisions, workplace tests, or law enforcement situations."
                )

                disclaimerCard(
                    icon: "lock.shield.fill",
                    title: "Privacy — on-device only",
                    body: "Eye images are processed only on your iPhone. Nothing is uploaded. Frames are not stored or sent to any server."
                )

                Button(action: onAcknowledge) {
                    Text("I understand — for entertainment only")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
    }

    private func disclaimerCard(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }
}
