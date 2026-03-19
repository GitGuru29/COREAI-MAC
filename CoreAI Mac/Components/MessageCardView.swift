import SwiftUI

struct MessageCardView: View {
    let message: ChatMessage
    @State private var isHovering = false

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
        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(message.role == .assistant ? "CoreAI" : "You")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                if let metadata = message.metadata {
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
            } else if let metadata = message.metadata {
                HStack(spacing: 14) {
                    metadataItem("Model", metadata.model)
                    metadataItem("Duration", metadata.totalDurationText)
                    metadataItem("Eval", metadata.evalCountText)
                    Spacer()
                    if message.role == .assistant && !message.text.isEmpty {
                        ResponseActionsView(
                            text: message.text,
                            isHovering: isHovering
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: message.role == .assistant ? 860 : 620, alignment: .leading)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(message.role == .assistant ? 0.08 : 0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(message.role == .assistant ? 0.16 : 0.08), radius: 16, y: 8)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(backgroundStyle)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(message.role == .assistant ? 0.06 : 0.03),
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
        return AnyShapeStyle(Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private var messageContent: some View {
        if message.state == .loading {
            LoadingIndicatorView(title: "Thinking…")
        } else if message.state == .streaming && message.text.isEmpty {
            LoadingIndicatorView(title: "Streaming…")
        } else if message.role == .assistant {
            Text(message.text.isEmpty ? " " : message.text)
                .font(.system(size: 15.5, weight: .regular, design: .default))
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(message.text.isEmpty ? " " : message.text)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
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
