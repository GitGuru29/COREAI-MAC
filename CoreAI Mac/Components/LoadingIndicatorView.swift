import SwiftUI

struct LoadingIndicatorView: View {
    let title: String
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 9) {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary.opacity(phase == index ? 0.9 : 0.35))
                        .frame(width: phase == index ? 7 : 6, height: phase == index ? 7 : 6)
                        .animation(.easeInOut(duration: 0.22), value: phase)
                }
            }
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.05), in: Capsule())
        .task {
            while !Task.isCancelled {
                phase = (phase + 1) % 3
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }
    }
}
