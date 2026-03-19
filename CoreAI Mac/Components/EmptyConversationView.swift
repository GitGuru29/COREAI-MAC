import SwiftUI

struct EmptyConversationView: View {
    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 102, height: 102)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.cyan.opacity(0.16), radius: 18, y: 4)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.45),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 122, height: 122)
                    .blur(radius: 0.5)

                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.92),
                                .secondary.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("Start Building With CoreAI")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Ask for code, architecture help, debugging, or analysis. Long responses stream directly into this workspace while your local backend runs.")
                    .font(.body.weight(.regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 520)
            }

            HStack(spacing: 10) {
                hintPill("Sample apps")
                hintPill("Refactors")
                hintPill("Code reviews")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func hintPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.04), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}
