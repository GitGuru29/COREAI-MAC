import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        PremiumChatView(viewModel: viewModel)
    }
}
