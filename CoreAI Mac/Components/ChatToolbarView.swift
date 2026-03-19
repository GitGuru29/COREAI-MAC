import SwiftUI

struct ChatToolbarView: View {
    @Binding var selectedModel: String
    @Binding var temperature: Double
    @Binding var automaticRoutingEnabled: Bool
    let availableModels: [ModelInfo]
    let isLoadingModels: Bool
    let canRetryLastRequest: Bool
    let routingDecisionTitle: String?
    let onModelChanged: () -> Void
    let onReloadModels: () -> Void
    let onClearConversation: () -> Void
    let onRetryLastRequest: () -> Void
    let onAutomaticRoutingChanged: (Bool) -> Void

    var body: some View {
        // Gemini-style: centered floating pill
        HStack(spacing: 0) {
            // Model section
            HStack(spacing: 8) {
                Image(systemName: "cpu")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Picker("Model", selection: $selectedModel) {
                    ForEach(availableModels) { model in
                        Text(model.name).tag(model.name)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
                .labelsHidden()
                .onChange(of: selectedModel) { _, _ in onModelChanged() }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            pillDivider

            // Temperature
            HStack(spacing: 8) {
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)

                Slider(value: $temperature, in: 0...1, step: 0.1)
                    .frame(width: 90)

                Text(String(format: "%.1f", temperature))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 22, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            pillDivider

            // Actions cluster
            HStack(spacing: 4) {
                if let routingTitle = routingDecisionTitle, automaticRoutingEnabled {
                    Text(routingTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.trailing, 6)
                }

                iconPillButton("arrow.triangle.2.circlepath", label: "Reload models") {
                    onReloadModels()
                }
                .disabled(isLoadingModels)
                .opacity(isLoadingModels ? 0.4 : 1)

                if canRetryLastRequest {
                    iconPillButton("arrow.clockwise", label: "Retry") {
                        onRetryLastRequest()
                    }
                }

                Menu {
                    Toggle("Automatic Model Routing", isOn: $automaticRoutingEnabled)
                        .onChange(of: automaticRoutingEnabled) { _, v in onAutomaticRoutingChanged(v) }
                    Divider()
                    Button("Clear Chat", role: .destructive, action: onClearConversation)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(toolbarBackground)
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.22), Color.indigo.opacity(0.14)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.14), radius: 18, y: 6)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var toolbarBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.07), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }

    private var pillDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(width: 1, height: 22)
    }

    private func iconPillButton(_ imageName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(label)
    }
}
