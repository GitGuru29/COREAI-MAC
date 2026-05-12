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
    @State private var isFocused = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Advanced options drawer
            if showsAdvancedOptions {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("System prompt (optional)", text: $systemPrompt)
                            .textFieldStyle(.roundedBorder)
                        TextField("Keep alive", text: $keepAlive)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Main composer area
            VStack(spacing: 0) {
                // Text field with loading overlay
                ZStack(alignment: .center) {
                    ComposerTextView(
                        text: $text,
                        placeholder: isSending ? "" : "Message CoreAI…",
                        onSubmit: onSend
                    )
                    .opacity(isSending ? 0.3 : 1.0)
                    .disabled(isSending)
                    
                    if isSending {
                        LoadingIndicatorView(title: "Generating…")
                    }
                }
                .frame(minHeight: 52, maxHeight: 130)
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 6)

                // Bottom row: accessories + hints + send
                HStack(alignment: .center, spacing: 10) {
                    // Left: accessory icons
                    HStack(spacing: 6) {
                        accessoryButton(systemImage: "paperclip", label: "Attach file") {}
                        accessoryButton(systemImage: "photo", label: "Attach image") {}
                        accessoryButton(systemImage: "mic", label: "Voice input") {}

                        Divider()
                            .frame(height: 16)
                            .opacity(0.4)

                        Button {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                                showsAdvancedOptions.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: showsAdvancedOptions ? "chevron.down" : "slider.horizontal.3")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Options")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    // Center: character hint
                    if characterCount > 0 {
                        PromptCharacterCounter(count: characterCount, max: maxCharacterCount)
                    } else {
                        Text("⏎ send  ⇧⏎ newline")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    // Right: send button (automatically disabled while generating)
                    sendButton
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
        }
        .background(composerBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(isFocused ? 0.32 : 0.10),
                            Color.indigo.opacity(isFocused ? 0.22 : 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.18), radius: 20, y: 8)
        .shadow(color: Color.cyan.opacity(isFocused ? 0.06 : 0), radius: 14, y: 4)
        .animation(.easeOut(duration: 0.2), value: isFocused)
        .onHover { isFocused = $0 }
    }

    private var composerBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.07), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: canSend
                                    ? [Color.cyan.opacity(0.95), Color.blue, Color.indigo]
                                    : [Color.primary.opacity(0.15), Color.primary.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                .shadow(color: canSend ? Color.cyan.opacity(0.35) : .clear, radius: 12, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .animation(.easeOut(duration: 0.18), value: canSend)
    }

    private func accessoryButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.04), in: Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .help(label)
    }
}
