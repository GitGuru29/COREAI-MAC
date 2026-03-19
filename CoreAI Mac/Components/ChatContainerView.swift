import SwiftUI

struct ChatContainerView: View {
    let messages: [ChatMessage]
    let isSending: Bool

    var body: some View {
        ConversationSurfaceView(messages: messages, isSending: isSending)
    }
}
