import SwiftUI

struct PremiumChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let contentMaxWidth: CGFloat = 1120

    var body: some View {
        ZStack {
            backgroundLayer
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ChatToolbarView(
                    selectedModel: $viewModel.selectedModel,
                    temperature: $viewModel.temperature,
                    automaticRoutingEnabled: $viewModel.automaticModelRoutingEnabled,
                    availableModels: viewModel.availableModels,
                    isLoadingModels: viewModel.isLoadingModels,
                    canRetryLastRequest: viewModel.canRetryLastRequest,
                    routingDecisionTitle: viewModel.lastRoutingDecision.map { "\($0.category.displayTitle) -> \($0.model)" },
                    onModelChanged: viewModel.persistSelectedModel,
                    onReloadModels: {
                        Task { await viewModel.refreshModels() }
                    },
                    onClearConversation: viewModel.clearConversation,
                    onRetryLastRequest: {
                        Task { await viewModel.retryLastRequest() }
                    },
                    onAutomaticRoutingChanged: viewModel.setAutomaticModelRoutingEnabled
                )
                .frame(maxWidth: contentMaxWidth)
                .padding(.top, 2)

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
            .padding(.horizontal, 26)
            .padding(.vertical, 18)
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
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(Color.cyan.opacity(colorScheme == .dark ? 0.08 : 0.05))
                .frame(width: 680, height: 680)
                .blur(radius: 160)
                .offset(x: 340, y: -310)

            Circle()
                .fill(Color.indigo.opacity(colorScheme == .dark ? 0.11 : 0.05))
                .frame(width: 620, height: 620)
                .blur(radius: 150)
                .offset(x: -410, y: -260)

            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.09 : 0.04))
                .frame(width: 540, height: 540)
                .blur(radius: 160)
                .offset(x: 90, y: 330)

            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.20 : 0.08))
                .frame(maxWidth: 1180, maxHeight: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 44, style: .continuous)
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12), lineWidth: 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                )

            meshOverlay
        }
    }

    private var meshOverlay: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                var path = Path()
                let spacing: CGFloat = 72

                for x in stride(from: 0, through: size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }

                for y in stride(from: 0, through: size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }

                let opacity = colorScheme == .dark ? 0.035 : 0.025
                context.opacity = opacity
                context.addFilter(.blur(radius: 0.3))
                context.stroke(path, with: .color(.white), lineWidth: 0.6)

                let glowX = size.width * 0.5 + CGFloat(sin(t * 0.18)) * 160
                let glowY = size.height * 0.42 + CGFloat(cos(t * 0.16)) * 90
                let rect = CGRect(x: glowX - 180, y: glowY - 180, width: 360, height: 360)
                context.addFilter(.blur(radius: 80))
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(Color.white.opacity(colorScheme == .dark ? 0.03 : 0.02))
                )
            }
        }
        .ignoresSafeArea()
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }

    private var backgroundGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.04, green: 0.05, blue: 0.08),
                Color(red: 0.05, green: 0.06, blue: 0.10),
                Color(red: 0.02, green: 0.03, blue: 0.05)
            ]
        }

        return [
            Color(nsColor: .windowBackgroundColor),
            Color(nsColor: .underPageBackgroundColor),
            Color.white
        ]
    }
}
