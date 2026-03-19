import AppKit
import SwiftUI

struct ResponseActionsView: View {
    let text: String
    let isHovering: Bool

    var body: some View {
        HStack(spacing: 8) {
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(buttonBackground, in: Capsule())
            .foregroundStyle(isHovering ? .primary : .secondary)
            .scaleEffect(isHovering ? 1 : 0.98)
            .animation(.easeOut(duration: 0.16), value: isHovering)
        }
    }

    private var buttonBackground: some ShapeStyle {
        AnyShapeStyle(Color.white.opacity(isHovering ? 0.08 : 0.04))
    }
}
