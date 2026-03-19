import SwiftUI

struct MessageCardView: View {
    let message: ChatMessage
    @State private var isHovering = false
    @State private var hasAppeared = false

    var body: some View {
        Group {
            if message.role == .assistant {
                assistantRow
            } else {
                userRow
            }
        }
        .offset(y: hasAppeared ? 0 : 10)
        .opacity(hasAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Assistant row (Claude-style: avatar left, text right, no card)

    private var assistantRow: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar orb
            assistantAvatar

            VStack(alignment: .leading, spacing: 8) {
                // Message content
                messageContent

                // Error
                if case .error(let errorText) = message.state {
                    Text(errorText)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.72))
                }

                // Metadata + action row
                if let metadata = message.metadata, message.role == .assistant {
                    HStack(spacing: 10) {
                        metadataRow(metadata)
                        Spacer()
                        if !message.text.isEmpty {
                            ResponseActionsView(text: message.text, isHovering: isHovering)
                        }
                    }
                }
            }
            .frame(maxWidth: 860, alignment: .leading)

            Spacer(minLength: 40)
        }
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.16)) { isHovering = hovering }
        }
    }

    // MARK: - User row (ChatGPT-style: pill bubble, right-aligned)

    private var userRow: some View {
        HStack {
            Spacer(minLength: 80)
            Text(message.text.isEmpty ? " " : message.text)
                .font(.body.weight(.regular))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .textSelection(.enabled)
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(userBubbleBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 10, y: 4)
                .frame(maxWidth: 640, alignment: .trailing)
        }
    }

    // MARK: - Sub-views

    private var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [Color.cyan, Color.blue, Color.indigo, Color.cyan],
                        center: .center
                    )
                )
                .frame(width: 32, height: 32)
            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .shadow(color: Color.cyan.opacity(0.30), radius: 8, y: 2)
    }

    @ViewBuilder
    private var messageContent: some View {
        if message.state == .loading {
            HStack(spacing: 6) {
                LoadingIndicatorView(title: "Thinking")
            }
            .padding(.top, 4)
        } else if message.state == .streaming && message.text.isEmpty {
            LoadingIndicatorView(title: "Writing")
                .padding(.top, 4)
        } else if message.role == .assistant {
            VStack(alignment: .leading, spacing: 6) {
                Text(message.text.isEmpty ? " " : message.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.primary)
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if message.state == .streaming {
                    LoadingIndicatorView(title: "Generating")
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
        }
    }

    private var userBubbleBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.14, blue: 0.26),
                        Color(red: 0.09, green: 0.10, blue: 0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private func metadataRow(_ metadata: ChatMessageMetadata) -> some View {
        HStack(spacing: 10) {
            metaChip(metadata.model)
            metaChip(metadata.totalDurationText)
            metaChip(metadata.evalCountText + " tok")
        }
    }

    private func metaChip(_ value: String) -> some View {
        Text(value)
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.secondary.opacity(0.7))
    }
}
