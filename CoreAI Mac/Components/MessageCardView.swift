import SwiftUI

struct MessageCardView: View {
    let message: ChatMessage
    @State private var isHovering = false
    @State private var hasAppeared = false

    var body: some View {
        HStack {
            if message.role == .assistant {
                card
                Spacer(minLength: 72)
            } else {
                Spacer(minLength: 120)
                card
            }
        }
        .offset(y: hasAppeared ? 0 : 8)
        .opacity(hasAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                hasAppeared = true
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(message.role == .assistant ? "CoreAI" : "You")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                if message.role == .assistant, let metadata = message.metadata {
                    Text(metadata.createdAtText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            messageContent

            if case .error(let errorText) = message.state {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if message.role == .assistant, let metadata = message.metadata {
                HStack(spacing: 12) {
                    metadataItem("Model", metadata.model)
                    metadataItem("Duration", metadata.totalDurationText)
                    metadataItem("Eval", metadata.evalCountText)
                    Spacer()
                    if !message.text.isEmpty {
                        ResponseActionsView(
                            text: message.text,
                            isHovering: isHovering
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: message.role == .assistant ? 800 : 500, alignment: .leading)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(message.role == .assistant ? 0.08 : 0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(message.role == .assistant ? 0.14 : 0.06), radius: 14, y: 6)
        .scaleEffect(isHovering && message.role == .assistant ? 1.004 : 1)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.16)) {
                isHovering = hovering
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(backgroundStyle)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(message.role == .assistant ? 0.065 : 0.03),
                                message.role == .assistant ? Color.cyan.opacity(0.015) : Color.blue.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var backgroundStyle: AnyShapeStyle {
        if message.role == .assistant {
            return AnyShapeStyle(.regularMaterial)
        }
        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.10),
                    Color.indigo.opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    @ViewBuilder
    private var messageContent: some View {
        if message.state == .loading {
            VStack(alignment: .leading, spacing: 8) {
                LoadingIndicatorView(title: "Thinking")
                Text("Preparing the response.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else if message.state == .streaming && message.text.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                LoadingIndicatorView(title: "Generating")
                Text("Writing the response now.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else if message.role == .assistant {
            VStack(alignment: .leading, spacing: 8) {
                Text(message.text.isEmpty ? " " : message.text)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if message.state == .streaming {
                    LoadingIndicatorView(title: "Generating")
                        .transition(.opacity)
                }
            }
        } else {
            Text(message.text.isEmpty ? " " : message.text)
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.95))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func metadataItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
