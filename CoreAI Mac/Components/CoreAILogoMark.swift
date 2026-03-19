import SwiftUI

struct CoreAILogoMark: View {
    var size: CGFloat = 92
    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    @State private var shimmer: Double = 0

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.28),
                            Color.indigo.opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.62
                    )
                )
                .frame(width: size * 1.35, height: size * 1.35)
                .scaleEffect(pulse ? 1.08 : 0.94)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)

            // Base orb
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color.cyan,
                            Color(red: 0.38, green: 0.52, blue: 1.0),
                            Color.indigo,
                            Color.purple.opacity(0.85),
                            Color.cyan
                        ],
                        center: .center
                    )
                )
                .frame(width: size * 0.72, height: size * 0.72)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: rotation)

            // Overlay shimmer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.0)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.38
                    )
                )
                .frame(width: size * 0.72, height: size * 0.72)

            // Inner sparkle mark
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.3, weight: .medium))
                .foregroundStyle(.white.opacity(0.90))
                .shadow(color: .white.opacity(0.6), radius: 6)
        }
        .frame(width: size, height: size)
        .onAppear {
            rotation = 360
            pulse = true
        }
    }
}
