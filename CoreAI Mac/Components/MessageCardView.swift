import AppKit
import SwiftUI

struct MessageCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let message: ChatMessage
    @State private var hasAppeared = false
    @State private var copied = false
    @State private var thumbsUp = false
    @State private var thumbsDown = false

    private var shouldShowAssistantFooter: Bool {
        message.role == .assistant && (!message.text.isEmpty || message.metadata != nil)
    }

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

                if shouldShowAssistantFooter {
                    VStack(alignment: .leading, spacing: 8) {
                        if let metadata = message.metadata {
                            metadataRow(metadata)
                        }
                        if !message.text.isEmpty {
                            actionRow
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: 860, alignment: .leading)

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var actionRow: some View {
        HStack(spacing: 10) {
            actionButton(
                systemImage: thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup",
                label: "Like",
                active: thumbsUp
            ) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) {
                    thumbsUp.toggle()
                    if thumbsUp { thumbsDown = false }
                }
            }

            actionButton(
                systemImage: thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown",
                label: "Dislike",
                active: thumbsDown
            ) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) {
                    thumbsDown.toggle()
                    if thumbsDown { thumbsUp = false }
                }
            }

            actionButton(
                systemImage: copied ? "checkmark" : "doc.on.doc",
                label: copied ? "Copied!" : "Copy",
                active: copied
            ) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(message.text, forType: .string)
                withAnimation(.spring(response: 0.24, dampingFraction: 0.7)) {
                    copied = true
                }
                Task {
                    try? await Task.sleep(nanoseconds: 1_800_000_000)
                    withAnimation { copied = false }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 2)
    }

    private func actionButton(
        systemImage: String,
        label: String,
        active: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(active ? Color.cyan : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(active ? Color.cyan.opacity(0.24) : actionButtonBackgroundColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(active ? Color.cyan.opacity(0.40) : actionButtonBorderColor, lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.20 : 0.08), radius: 6, y: 2)
    }

    private func metaChip(_ value: String) -> some View {
        Text(value)
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.secondary.opacity(0.7))
    }

    private var actionButtonBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.white.opacity(0.98)
    }

    private var actionButtonBorderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.22) : Color.black.opacity(0.10)
    }
}
