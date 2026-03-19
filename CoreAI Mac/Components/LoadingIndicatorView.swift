import SwiftUI

struct LoadingIndicatorView: View {
    let title: String
    @State private var phase = 0

    private let barCount = 4
    private let heights: [CGFloat] = [6, 10, 14, 10]

    var body: some View {
        HStack(spacing: 6) {
            // Gemini-style animated wave bars
            HStack(spacing: 3) {
                ForEach(0..<barCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue, Color.indigo],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3, height: phase == index ? 16 : heights[index])
                        .animation(
                            .easeInOut(duration: 0.30).delay(Double(index) * 0.07),
                            value: phase
                        )
                }
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .task {
            while !Task.isCancelled {
                phase = (phase + 1) % barCount
                try? await Task.sleep(nanoseconds: 280_000_000)
            }
        }
    }
}
