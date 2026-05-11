import SwiftUI

struct SummarizeView: View {
    @ObservedObject var viewModel: SummarizeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Picker("Model", selection: $viewModel.selectedModel) {
                                ForEach(viewModel.availableModels) { model in
                                    Text(model.name).tag(model.name)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Style", selection: $viewModel.style) {
                                Text("brief").tag("brief")
                                Text("detailed").tag("detailed")
                                Text("bullets").tag("bullets")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: 240)

                            Spacer()

                            if viewModel.isRunning {
                                Text(viewModel.isStreaming ? "Streaming… \(viewModel.elapsedSeconds)s" : "Running… \(viewModel.elapsedSeconds)s")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        TextEditor(text: $viewModel.sourceText)
                            .frame(minHeight: 220)
                            .font(.body)

                        HStack {
                            PromptCharacterCounter(count: viewModel.characterCount, max: 12000)
                            Spacer()
                            if viewModel.isRunning {
                                Button("Cancel", action: viewModel.cancel)
                            }
                            Button("Summarize") {
                                viewModel.run()
                            }
                            .disabled(!viewModel.canSubmit)
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    ConnectionBanner(style: .failed, title: "Summarize Error", message: errorMessage)
                }

                GroupBox("Summary") {
                    VStack(alignment: .leading, spacing: 12) {
                        if viewModel.outputText.isEmpty && !viewModel.isRunning {
                            EmptyStateView(
                                title: "No Summary Yet",
                                message: "Paste content and start a summarize request."
                            )
                            .frame(minHeight: 220)
                        } else {
                            Text(viewModel.outputText.isEmpty ? "Waiting for stream…" : viewModel.outputText)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if !viewModel.lastModel.isEmpty {
                            Divider()
                            LabeledValueRow(label: "Model", value: viewModel.lastModel)
                            if !viewModel.lastCreatedAt.isEmpty {
                                LabeledValueRow(label: "Created", value: viewModel.lastCreatedAt)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Summarize")
        .task {
            await viewModel.load()
        }
    }
}
