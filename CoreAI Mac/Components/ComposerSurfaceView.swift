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
    @State private var showsAdvancedOptions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        showsAdvancedOptions.toggle()
                    }
                } label: {
                    Label("Advanced", systemImage: showsAdvancedOptions ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Enter to send, Shift+Enter for newline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if showsAdvancedOptions {
                HStack(spacing: 8) {
                    TextField("System prompt (optional)", text: $systemPrompt)
                        .textFieldStyle(.roundedBorder)

                    TextField("Keep alive", text: $keepAlive)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 108)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ZStack(alignment: .bottomTrailing) {
                ComposerTextView(
                    text: $text,
                    placeholder: "Ask something…",
                    onSubmit: onSend
                )
                .frame(minHeight: 64, maxHeight: 110)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.primary.opacity(0.035))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.05),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)

                HStack(spacing: 8) {
                    floatingAccessory(systemImage: "plus")
                    floatingAccessory(systemImage: "paperclip")
                }
                .padding(.leading, 10)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                Button {
                    onSend()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.bold))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.95),
                                    Color.blue.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(Circle().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                .shadow(color: Color.cyan.opacity(0.28), radius: 14, y: 4)
                .disabled(!canSend || isSending)
                .opacity(canSend && !isSending ? 1 : 0.55)
                .padding(8)
            }

            HStack {
                PromptCharacterCounter(count: characterCount, max: maxCharacterCount)
                Spacer()
                if isSending {
                    LoadingIndicatorView(title: "Generating")
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.07),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 16, y: 8)
    }

    private func floatingAccessory(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 24, height: 24)
            .background(Color.white.opacity(0.04), in: Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}
