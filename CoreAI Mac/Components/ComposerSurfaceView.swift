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
        VStack(alignment: .leading, spacing: 12) {
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
                HStack(spacing: 10) {
                    TextField("System prompt (optional)", text: $systemPrompt)
                        .textFieldStyle(.roundedBorder)

                    TextField("Keep alive", text: $keepAlive)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ZStack(alignment: .bottomTrailing) {
                ComposerTextView(
                    text: $text,
                    placeholder: "Ask something…",
                    onSubmit: onSend
                )
                .frame(minHeight: 82, maxHeight: 150)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.primary.opacity(0.035))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 10, y: 4)

                HStack(spacing: 8) {
                    floatingAccessory(systemImage: "plus")
                    floatingAccessory(systemImage: "paperclip")
                }
                .padding(.leading, 12)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                Button {
                    onSend()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.bold))
                        .frame(width: 44, height: 44)
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
                .padding(10)
            }

            HStack {
                PromptCharacterCounter(count: characterCount, max: maxCharacterCount)
                Spacer()
                if isSending {
                    LoadingIndicatorView(title: "Generating")
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 20, y: 12)
    }

    private func floatingAccessory(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 28, height: 28)
            .background(Color.white.opacity(0.04), in: Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}
