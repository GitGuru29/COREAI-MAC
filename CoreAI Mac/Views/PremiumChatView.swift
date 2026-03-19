import SwiftUI

struct PremiumChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let contentMaxWidth: CGFloat = 900

    var body: some View {
        ZStack {
            backgroundLayer
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Toolbar: centered floating pill at top
                ChatToolbarView(
                    selectedModel: $viewModel.selectedModel,
                    temperature: $viewModel.temperature,
                    automaticRoutingEnabled: $viewModel.automaticModelRoutingEnabled,
                    availableModels: viewModel.availableModels,
                    isLoadingModels: viewModel.isLoadingModels,
                    canRetryLastRequest: viewModel.canRetryLastRequest,
                    routingDecisionTitle: viewModel.lastRoutingDecision.map { "\($0.category.displayTitle) → \($0.model)" },
                    onModelChanged: viewModel.persistSelectedModel,
                    onReloadModels: { Task { await viewModel.refreshModels() } },
                    onClearConversation: viewModel.clearConversation,
                    onRetryLastRequest: { Task { await viewModel.retryLastRequest() } },
                    onAutomaticRoutingChanged: viewModel.setAutomaticModelRoutingEnabled
                )
                .frame(maxWidth: 680)
                .padding(.top, 16)
                .padding(.bottom, 10)

                // Full-bleed frameless conversation surface
                ConversationSurfaceView(
                    messages: viewModel.messages,
                    isSending: viewModel.isSending
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom composer + error area
                VStack(spacing: 8) {
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 6)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    ComposerSurfaceView(
                        text: $viewModel.prompt,
                        systemPrompt: $viewModel.systemPrompt,
                        keepAlive: $viewModel.keepAlive,
                        characterCount: viewModel.characterCount,
                        maxCharacterCount: viewModel.maxPromptChars,
                        isSending: viewModel.isSending,
                        canSend: viewModel.canSend,
                        onSend: { Task { await viewModel.send() } }
                    )
                }
                .frame(maxWidth: contentMaxWidth)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Chat")
        .task { await viewModel.load() }
    }

    // MARK: - Aurora background (preserved + refined)

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: backgroundGradientColors,
                startPoint: .top,
                endPoint: .bottom
            )

            // Cyan aurora blob — top right
            Circle()
                .fill(Color.cyan.opacity(colorScheme == .dark ? 0.10 : 0.06))
                .frame(width: 700, height: 700)
                .blur(radius: 170)
                .offset(x: 370, y: -320)

            // Indigo aurora blob — top left
            Circle()
                .fill(Color.indigo.opacity(colorScheme == .dark ? 0.13 : 0.06))
                .frame(width: 640, height: 640)
                .blur(radius: 160)
                .offset(x: -430, y: -270)

            // Blue aurora blob — bottom center
            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.10 : 0.05))
                .frame(width: 560, height: 560)
                .blur(radius: 170)
                .offset(x: 80, y: 360)

            meshOverlay
        }
    }

    private var meshOverlay: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                // Subtle grid lines
                var path = Path()
                let spacing: CGFloat = 80

                for x in stride(from: 0, through: size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }

                context.opacity = colorScheme == .dark ? 0.028 : 0.018
                context.stroke(path, with: .color(.white), lineWidth: 0.5)

                // Roaming soft glow
                let glowX = size.width * 0.5 + CGFloat(sin(t * 0.16)) * 180
                let glowY = size.height * 0.44 + CGFloat(cos(t * 0.14)) * 100
                let rect = CGRect(x: glowX - 200, y: glowY - 200, width: 400, height: 400)
                context.addFilter(.blur(radius: 90))
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(Color.white.opacity(colorScheme == .dark ? 0.028 : 0.018))
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
                Color(red: 0.04, green: 0.05, blue: 0.09),
                Color(red: 0.05, green: 0.06, blue: 0.11),
                Color(red: 0.02, green: 0.03, blue: 0.06)
            ]
        }
        return [
            Color(nsColor: .windowBackgroundColor),
            Color(nsColor: .underPageBackgroundColor),
            Color.white
        ]
    }
}
