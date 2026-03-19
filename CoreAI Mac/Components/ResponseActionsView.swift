import AppKit
import SwiftUI

struct ResponseActionsView: View {
    let text: String
    let isHovering: Bool
    @State private var copied = false
    @State private var thumbsUp = false
    @State private var thumbsDown = false

    var body: some View {
        HStack(spacing: 4) {
            actionButton(
                systemImage: thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup",
                label: "Helpful",
                active: thumbsUp
            ) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) {
                    thumbsUp.toggle()
                    if thumbsUp { thumbsDown = false }
                }
            }

            actionButton(
                systemImage: thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown",
                label: "Not helpful",
                active: thumbsDown
            ) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) {
                    thumbsDown.toggle()
                    if thumbsDown { thumbsUp = false }
                }
            }

            Divider()
                .frame(height: 14)
                .opacity(0.4)
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
        .opacity(isHovering ? 1 : 0)
        .offset(y: isHovering ? 0 : 4)
        .animation(.easeOut(duration: 0.18), value: isHovering)
    }

    private func actionButton(
        systemImage: String,
        label: String,
        active: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(active ? Color.cyan : Color.secondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(active ? Color.cyan.opacity(0.12) : Color.primary.opacity(0.05))
                )
                .overlay(
                    Circle()
                        .strokeBorder(active ? Color.cyan.opacity(0.25) : Color.white.opacity(0.05), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .help(label)
        .scaleEffect(active ? 1.08 : 1)
    }
}
