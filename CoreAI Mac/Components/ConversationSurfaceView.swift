import SwiftUI

struct ConversationSurfaceView: View {
    let messages: [ChatMessage]
    let isSending: Bool

    private let contentMaxWidth: CGFloat = 860

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    if messages.isEmpty {
                        EmptyConversationView()
                            .frame(maxWidth: .infinity, minHeight: 420)
                    } else {
                        ForEach(messages) { message in
                            MessageCardView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
            // "Latest" pill — bottom center (ChatGPT-style)
            .overlay(alignment: .bottom) {
                if !messages.isEmpty {
                    Button {
                        scrollToLatest(proxy: proxy)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Latest")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 12, y: 4)
                    .padding(.bottom, 10)
                }
            }
            .onChange(of: messages.count) { _, _ in scrollToLatest(proxy: proxy) }
            .onChange(of: lastMessageText) { _, _ in scrollToLatest(proxy: proxy) }
            .animation(.easeOut(duration: 0.22), value: messages)
        }
    }

    private var lastMessageText: String { messages.last?.text ?? "" }

    private func scrollToLatest(proxy: ScrollViewProxy) {
        guard let lastID = messages.last?.id else { return }
        withAnimation(.easeOut(duration: 0.22)) {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }
}
