import SwiftUI

struct ChatToolbarView: View {
    @Binding var selectedModel: String
    @Binding var temperature: Double
    let availableModels: [ModelInfo]
    let isLoadingModels: Bool
    let onModelChanged: () -> Void
    let onReloadModels: () -> Void
    let onClearConversation: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            toolbarCluster {
                Label("Model", systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

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
            }

            toolbarCluster {
                Text("Temperature")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Slider(value: $temperature, in: 0...1, step: 0.1)
                    .frame(width: 120)

                Text(String(format: "%.1f", temperature))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 26, alignment: .trailing)
            }

            Spacer(minLength: 0)

            toolbarCluster {
                Button {
                    onReloadModels()
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .disabled(isLoadingModels)

                Divider()
                    .frame(height: 16)

                Button("Clear Chat", action: onClearConversation)
                    .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 18, y: 8)
    }

    private func toolbarCluster<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 10) {
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
