import SwiftUI

struct PremiumChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let contentMaxWidth: CGFloat = 1080

    var body: some View {
        ZStack {
            backgroundLayer
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ChatToolbarView(
                    selectedModel: $viewModel.selectedModel,
                    temperature: $viewModel.temperature,
                    availableModels: viewModel.availableModels,
                    isLoadingModels: viewModel.isLoadingModels,
                    onModelChanged: viewModel.persistSelectedModel,
                    onReloadModels: {
                        Task { await viewModel.refreshModels() }
                    },
                    onClearConversation: viewModel.clearConversation
                )
                .frame(maxWidth: contentMaxWidth)

                ConversationSurfaceView(
                    messages: viewModel.messages,
                    isSending: viewModel.isSending
                )
                .frame(maxWidth: contentMaxWidth, maxHeight: .infinity)

                VStack(spacing: 10) {
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.secondary)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 6)
                    }

                    ComposerSurfaceView(
                        text: $viewModel.prompt,
                        systemPrompt: $viewModel.systemPrompt,
                        keepAlive: $viewModel.keepAlive,
                        characterCount: viewModel.characterCount,
                        maxCharacterCount: viewModel.maxPromptChars,
                        isSending: viewModel.isSending,
                        canSend: viewModel.canSend,
                        onSend: {
                            Task { await viewModel.send() }
                        }
                    )
                }
                .frame(maxWidth: contentMaxWidth)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
        .navigationTitle("Chat")
        .task {
            await viewModel.load()
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: backgroundGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.16 : 0.07))
                .frame(width: 520, height: 520)
                .blur(radius: 120)
                .offset(x: 360, y: -280)

            Circle()
                .fill(Color.indigo.opacity(colorScheme == .dark ? 0.12 : 0.05))
                .frame(width: 460, height: 460)
                .blur(radius: 110)
                .offset(x: -420, y: -220)

            Circle()
                .fill(Color.cyan.opacity(colorScheme == .dark ? 0.08 : 0.04))
                .frame(width: 440, height: 440)
                .blur(radius: 130)
                .offset(x: 120, y: 340)
        }
    }

    private var backgroundGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .underPageBackgroundColor),
                Color.black.opacity(0.94)
            ]
        }

        return [
            Color(nsColor: .windowBackgroundColor),
            Color(nsColor: .underPageBackgroundColor),
            Color.white
        ]
    }
}
