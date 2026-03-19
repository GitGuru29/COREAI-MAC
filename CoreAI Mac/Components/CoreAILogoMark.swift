import SwiftUI

struct CoreAILogoMark: View {
    @State private var float = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.17, blue: 0.20),
                            Color(red: 0.24, green: 0.26, blue: 0.31)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: Color.black.opacity(0.16), radius: 18, y: 8)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.98, green: 0.80, blue: 0.51),
                            Color(red: 0.92, green: 0.53, blue: 0.28)
                        ],
                        center: .center,
                        startRadius: 6,
                        endRadius: 44
                    )
                )
                .frame(width: 52, height: 52)
                .offset(x: 10, y: float ? -6 : 6)
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        .padding(10)
                }

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .frame(width: 42, height: 42)
                .offset(x: -12, y: 10)
        }
        .frame(width: 92, height: 92)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                float = true
            }
        }
    }
}
