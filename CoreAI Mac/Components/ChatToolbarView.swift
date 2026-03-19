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
        HStack(spacing: 12) {
            HStack(spacing: 16) {
                compactLabel("Model")

                Picker("Model", selection: $selectedModel) {
                    ForEach(availableModels) { model in
                        Text(model.name).tag(model.name)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 230)
                .labelsHidden()
                .onChange(of: selectedModel) { _, _ in
                    onModelChanged()
                }

                Divider()
                    .frame(height: 18)

                compactLabel("Temp")

                Slider(value: $temperature, in: 0...1, step: 0.1)
                    .frame(width: 110)

                Text(String(format: "%.1f", temperature))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Spacer(minLength: 0)

            if automaticRoutingEnabled, let routingDecisionTitle {
                Text(routingDecisionTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                iconButton("arrow.triangle.2.circlepath", label: "Reload", action: onReloadModels)
                    .disabled(isLoadingModels)

                if canRetryLastRequest {
                    iconButton("arrow.clockwise.circle", label: "Retry", action: onRetryLastRequest)
                }

                Menu {
                    Toggle("Automatic Model Routing", isOn: $automaticRoutingEnabled)
                        .onChange(of: automaticRoutingEnabled) { _, newValue in
                            onAutomaticRoutingChanged(newValue)
                        }

                    Divider()

                    Button("Clear Chat", role: .destructive, action: onClearConversation)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
                .menuStyle(.borderlessButton)
            }
            .padding(6)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 16, y: 8)
    }

    private func compactLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func iconButton(_ systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(label)
    }
}
