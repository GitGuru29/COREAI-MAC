import SwiftUI

struct ConversationSurfaceView: View {
    let messages: [ChatMessage]
    let isSending: Bool

    private let conversationMaxWidth: CGFloat = 920

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if messages.isEmpty {
                        EmptyConversationView()
                            .frame(maxWidth: .infinity, minHeight: 460)
                    } else {
                        ForEach(messages) { message in
                            MessageCardView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .frame(maxWidth: conversationMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 26)
                .padding(.vertical, 28)
            }
            .background(surfaceBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.black.opacity(0.18), radius: 26, y: 14)
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
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.regularMaterial)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
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
