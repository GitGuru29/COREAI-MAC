import SwiftUI

struct AnalyzeCodeView: View {
    @ObservedObject var viewModel: AnalyzeCodeViewModel

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

                            TextField("Language", text: $viewModel.language)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)

                            Picker("Task", selection: $viewModel.task) {
                                Text("review").tag("review")
                                Text("explain").tag("explain")
                                Text("refactor").tag("refactor")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: 260)

                            Spacer()

                            if viewModel.isRunning {
                                Text(viewModel.isStreaming ? "Streaming… \(viewModel.elapsedSeconds)s" : "Running… \(viewModel.elapsedSeconds)s")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        TextEditor(text: $viewModel.sourceText)
                            .frame(minHeight: 260)
                            .font(.system(.body, design: .monospaced))

                        HStack {
                            PromptCharacterCounter(count: viewModel.characterCount, max: 12000)
                            Spacer()
                            if viewModel.isRunning {
                                Button("Cancel", action: viewModel.cancel)
                            }
                            Button("Analyze") {
                                viewModel.run()
                            }
                            .disabled(!viewModel.canSubmit)
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    ConnectionBanner(style: .failed, title: "Analyze Error", message: errorMessage)
                }

                GroupBox("Analysis") {
                    VStack(alignment: .leading, spacing: 12) {
                        if viewModel.outputText.isEmpty && !viewModel.isRunning {
                            EmptyStateView(
                                title: "No Analysis Yet",
                                message: "Paste source code and start an analysis request."
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
                            LabeledValueRow(label: "Language", value: viewModel.lastLanguage)
                            LabeledValueRow(label: "Task", value: viewModel.lastTask)
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Analyze Code")
        .task {
            await viewModel.load()
        }
    }
}
