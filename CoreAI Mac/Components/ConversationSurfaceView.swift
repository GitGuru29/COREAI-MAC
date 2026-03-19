import SwiftUI

struct ConversationSurfaceView: View {
    let messages: [ChatMessage]
    let isSending: Bool

    private let conversationMaxWidth: CGFloat = 900

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if messages.isEmpty {
                        EmptyConversationView()
                            .frame(maxWidth: .infinity, minHeight: 380)
                    } else {
                        ForEach(messages) { message in
                            MessageCardView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .frame(maxWidth: conversationMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 34)
                .padding(.vertical, 30)
            }
            .background(surfaceBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
            )
            .overlay(alignment: .bottomTrailing) {
                if !messages.isEmpty {
                    Button {
                        scrollToLatest(proxy: proxy)
                    } label: {
                        Label("Latest", systemImage: "arrow.down.circle.fill")
                            .font(.caption.weight(.semibold))
                            .labelStyle(.titleAndIcon)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 10, y: 4)
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.16), radius: 26, y: 12)
            .onChange(of: messages.count) { _, _ in
                scrollToLatest(proxy: proxy)
            }
            .onChange(of: lastMessageText) { _, _ in
                scrollToLatest(proxy: proxy)
            }
            .animation(.easeOut(duration: 0.22), value: messages)
        }
    }

    private var lastMessageText: String {
        messages.last?.text ?? ""
    }

    private var surfaceBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.015),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
    }

    private func scrollToLatest(proxy: ScrollViewProxy) {
        guard let lastID = messages.last?.id else {
            return
        }

        withAnimation(.easeOut(duration: 0.22)) {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }
}
