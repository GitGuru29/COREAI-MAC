import SwiftUI

struct ComposerSurfaceView: View {
    @Binding var text: String
    @Binding var systemPrompt: String
    @Binding var keepAlive: String
    let characterCount: Int
    let maxCharacterCount: Int
    let isSending: Bool
    let canSend: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                TextField("System prompt (optional)", text: $systemPrompt)
                    .textFieldStyle(.roundedBorder)

                TextField("Keep alive", text: $keepAlive)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 130)
            }

            ZStack(alignment: .bottomTrailing) {
                ComposerTextView(
                    text: $text,
                    placeholder: "Ask something…",
                    onSubmit: onSend
                )
                .frame(minHeight: 124, maxHeight: 220)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )

                Button {
                    onSend()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.bold))
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.plain)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.18), radius: 10, y: 5)
                .disabled(!canSend || isSending)
                .padding(14)
            }

            HStack {
                PromptCharacterCounter(count: characterCount, max: maxCharacterCount)
                Spacer()
                Text("Enter to send, Shift+Enter for newline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.06),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 22, y: 12)
    }
}
