import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Connection Settings")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Form {
                    TextField("Base URL", text: $viewModel.baseURL)
                        .textFieldStyle(.roundedBorder)

                    SecureField("API Key", text: $viewModel.apiKey)
                        .textFieldStyle(.roundedBorder)

                    TextField("Preferred Model", text: $viewModel.preferredModel)
                        .textFieldStyle(.roundedBorder)

                    Toggle("Enable Streaming By Default (Phase 2 placeholder)", isOn: $viewModel.streamingEnabledByDefault)
                }
                .formStyle(.grouped)

                HStack {
                    Button("Save Settings") {
                        viewModel.save()
                    }
                    .disabled(viewModel.isSaving)

                    Button("Test Connection") {
                        Task { await viewModel.testConnection() }
                    }
                    .disabled(viewModel.isTestingConnection)

                    if viewModel.isTestingConnection || viewModel.isSaving {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    ConnectionBanner(style: .failed, title: "Settings Error", message: errorMessage)
                }

                if let testMessage = viewModel.testMessage {
                    ConnectionBanner(style: .healthy, title: "Connection Test Passed", message: testMessage)
                }

                if let result = viewModel.testResult {
                    InfoCard(title: "Test Result") {
                        LabeledValueRow(label: "Service", value: result.health.service)
                        LabeledValueRow(label: "Version", value: result.health.version)
                        LabeledValueRow(label: "Ollama", value: result.health.ollamaStatus)
                        LabeledValueRow(label: "Auth Enabled", value: result.info.authEnabled ? "Yes" : "No")
                        LabeledValueRow(label: "Default Model", value: result.info.defaultModel)
                        LabeledValueRow(label: "Max Prompt Chars", value: String(result.info.maxPromptChars))

                        if let models = result.models?.models.map(\.name), !models.isEmpty {
                            Divider()
                            Text("Installed Models")
                                .font(.headline)

                            ForEach(models, id: \.self) { model in
                                Text(model)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .frame(minWidth: 700, minHeight: 560)
        .navigationTitle("Settings")
    }
}
