import SwiftUI

struct ModelsView: View {
    @ObservedObject var viewModel: ModelsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.models.isEmpty {
                LoadingStateView(title: "Loading Models", message: "Fetching installed backend models.")
            } else if let errorMessage = viewModel.errorMessage, viewModel.models.isEmpty {
                ErrorStateView(
                    title: "Could Not Load Models",
                    message: errorMessage,
                    buttonTitle: "Retry"
                ) {
                    Task { await viewModel.refresh() }
                }
            } else if viewModel.models.isEmpty {
                EmptyStateView(
                    title: "No Models Found",
                    message: "The backend did not return any installed models."
                )
            } else {
                List {
                    Section {
                        Picker("Preferred Model", selection: $viewModel.preferredModel) {
                            ForEach(viewModel.models) { model in
                                Text(model.name).tag(model.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.preferredModel) { _, newValue in
                            viewModel.selectPreferredModel(newValue)
                        }
                    } footer: {
                        Text("The preferred model is stored locally and used as the default selection for chat.")
                    }

                    Section("Installed Models") {
                        ForEach(viewModel.models) { model in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(model.name)
                                        .font(.headline)
                                    Spacer()
                                    if model.name == viewModel.preferredModel {
                                        ModelBadge(title: "Preferred")
                                    }
                                }

                                LabeledValueRow(label: "Family", value: model.details.family)
                                LabeledValueRow(label: "Parameters", value: model.details.parameterSize)
                                LabeledValueRow(label: "Quantization", value: model.details.quantizationLevel)
                                LabeledValueRow(label: "Modified", value: ISO8601DateFormatter.shared.displayString(from: model.modifiedAt) ?? model.modifiedAt)
                                LabeledValueRow(label: "Size", value: ByteCountFormatter.fileSize.string(fromByteCount: model.size))

                                Button("Use As Preferred Model") {
                                    viewModel.selectPreferredModel(model.name)
                                }
                                .buttonStyle(.link)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle("Models")
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
