import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox("Request") {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Model", selection: $viewModel.selectedModel) {
                            ForEach(viewModel.availableModels) { model in
                                Text(model.name).tag(model.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.selectedModel) { _, _ in
                            viewModel.persistSelectedModel()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("System Prompt")
                                .font(.headline)
                            TextEditor(text: $viewModel.systemPrompt)
                                .frame(minHeight: 80)
                                .font(.body)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prompt")
                                .font(.headline)
                            TextEditor(text: $viewModel.prompt)
                                .frame(minHeight: 180)
                                .font(.body)
                            PromptCharacterCounter(
                                count: viewModel.characterCount,
                                max: viewModel.maxPromptChars
                            )
                        }

                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Temperature")
                                Slider(value: $viewModel.temperature, in: 0...1, step: 0.1)
                                Text(String(format: "%.1f", viewModel.temperature))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Keep Alive")
                                TextField("5m", text: $viewModel.keepAlive)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }

                        HStack {
                            Button("Send") {
                                Task { await viewModel.send() }
                            }
                            .keyboardShortcut(.return, modifiers: [.command])
                            .disabled(!viewModel.canSend)

                            Button("Clear") {
                                viewModel.clear()
                            }
                            .disabled(viewModel.isSending && viewModel.response == nil)

                            if viewModel.isSending {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                if let errorMessage = viewModel.errorMessage {
                    ConnectionBanner(style: .failed, title: "Request Failed", message: errorMessage)
                }

                GroupBox("Response") {
                    VStack(alignment: .leading, spacing: 16) {
                        if let response = viewModel.response {
                            Text(response.response)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Divider()

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], alignment: .leading, spacing: 10) {
                                LabeledValueRow(label: "Model", value: response.model)
                                LabeledValueRow(label: "Created", value: ISO8601DateFormatter.shared.displayString(from: response.createdAt) ?? response.createdAt)
                                LabeledValueRow(label: "Total Duration", value: DurationFormatter.displayString(fromNanoseconds: response.totalDuration))
                                LabeledValueRow(label: "Load Duration", value: DurationFormatter.displayString(fromNanoseconds: response.loadDuration))
                                LabeledValueRow(label: "Prompt Eval Count", value: response.promptEvalCount.map(String.init) ?? "n/a")
                                LabeledValueRow(label: "Eval Count", value: response.evalCount.map(String.init) ?? "n/a")
                                LabeledValueRow(label: "Prompt Eval Duration", value: DurationFormatter.displayString(fromNanoseconds: response.promptEvalDuration))
                                LabeledValueRow(label: "Eval Duration", value: DurationFormatter.displayString(fromNanoseconds: response.evalDuration))
                            }
                        } else if viewModel.isSending {
                            LoadingStateView(title: "Waiting For Response", message: "The backend is processing the request.")
                        } else {
                            EmptyStateView(
                                title: "No Response Yet",
                                message: "Enter a prompt and send the first non-streaming chat request."
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
            }
            .padding(24)
        }
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await viewModel.refreshModels() }
                } label: {
                    Label("Reload Models", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isLoadingModels || viewModel.isSending)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
