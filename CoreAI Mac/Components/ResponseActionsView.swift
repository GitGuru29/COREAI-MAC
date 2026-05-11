import AppKit
import SwiftUI

struct ResponseActionsView: View {
    @Environment(\.colorScheme) private var colorScheme

    let text: String
    @State private var copied = false
    @State private var thumbsUp = false
    @State private var thumbsDown = false

    var body: some View {
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

            Divider()
                .frame(height: 14)
                .opacity(0.55)
                .padding(.horizontal, 2)

            actionButton(
                systemImage: copied ? "checkmark" : "doc.on.doc",
                label: copied ? "Copied!" : "Copy",
                active: copied
            ) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
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
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.10) : Color.white.opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(colorScheme == .dark ? Color.cyan.opacity(0.28) : Color.black.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08), radius: 10, y: 4)
        .zIndex(1)
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
                    .fill(active ? Color.cyan.opacity(0.24) : buttonBackgroundColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(active ? Color.cyan.opacity(0.40) : buttonBorderColor, lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
        .help(label)
        .contentShape(Capsule())
        .scaleEffect(active ? 1.03 : 1)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.20 : 0.08), radius: 6, y: 2)
    }

    private var buttonBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.white.opacity(0.98)
    }

    private var buttonBorderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.22) : Color.black.opacity(0.10)
    }
}
