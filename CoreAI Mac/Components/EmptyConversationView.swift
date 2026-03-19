import SwiftUI

struct EmptyConversationView: View {
    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            // Animated orb logo
            CoreAILogoMark(size: 88)

            // Headline + subtitle (Claude-style direct)
            VStack(spacing: 10) {
                Text("What can I help with?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Powered by your local Ollama backend. Ask anything.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // 2×2 Suggestion card grid (Claude-style)
            let suggestions: [(icon: String, title: String, subtitle: String, accent: Color)] = [
                ("hammer.fill",         "Build something",   "Start a new app, component, or module",        .cyan),
                ("ant.fill",            "Debug & fix",       "Diagnose errors, crashes, and logic bugs",      .orange),
                ("doc.text.magnifyingglass", "Review code",  "Architecture, style, and best-practice review", .indigo),
                ("pencil.and.sparkles", "Write & explain",   "Docs, commit messages, and plain explanations", .purple),
            ]

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                spacing: 14
            ) {
                ForEach(suggestions, id: \.title) { s in
                    SuggestionCard(icon: s.icon, title: s.title, subtitle: s.subtitle, accent: s.accent)
                }
            }
            .frame(maxWidth: 580)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

private struct SuggestionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accent: Color
    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(isHovering ? 0.07 : 0.03), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    isHovering ? accent.opacity(0.28) : Color.white.opacity(0.07),
                    lineWidth: 1
                )
        )
        .scaleEffect(isHovering ? 1.025 : 1)
        .shadow(color: isHovering ? accent.opacity(0.12) : Color.black.opacity(0.06), radius: isHovering ? 14 : 8, y: 4)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovering)
        .onHover { isHovering = $0 }
    }
}
