import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ConnectionBanner(
                    style: viewModel.bannerStyle,
                    title: viewModel.bannerTitle,
                    message: viewModel.bannerMessage
                )

                if viewModel.isLoading && viewModel.healthStatus == nil && viewModel.serverInfo == nil {
                    LoadingStateView(title: "Loading Dashboard", message: "Fetching server health and configuration.")
                } else if let errorMessage = viewModel.errorMessage, viewModel.healthStatus == nil && viewModel.serverInfo == nil {
                    ErrorStateView(
                        title: "Could Not Load Dashboard",
                        message: errorMessage,
                        buttonTitle: "Retry"
                    ) {
                        Task { await viewModel.refresh() }
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                        InfoCard(title: "Service") {
                            LabeledValueRow(label: "Name", value: viewModel.healthStatus?.service ?? "Unknown")
                            LabeledValueRow(label: "Version", value: viewModel.healthStatus?.version ?? "Unknown")
                            LabeledValueRow(label: "Mode", value: viewModel.healthStatus?.serverMode ?? "Unknown")
                        }

                        InfoCard(title: "Connection") {
                            LabeledValueRow(label: "Base URL", value: viewModel.baseURL)
                            LabeledValueRow(label: "Status", value: viewModel.connectionSnapshot.message)
                            LabeledValueRow(label: "Health", value: viewModel.healthStatus?.status.capitalized ?? "Unknown")
                            LabeledValueRow(label: "Ollama", value: viewModel.healthStatus?.ollamaStatus ?? "Unknown")
                            LabeledValueRow(label: "Auth Enabled", value: (viewModel.serverInfo?.authEnabled ?? false) ? "Yes" : "No")
                        }

                        InfoCard(title: "Default Model") {
                            LabeledValueRow(label: "Model", value: viewModel.healthStatus?.defaultModel ?? viewModel.serverInfo?.defaultModel ?? "Unknown")
                            LabeledValueRow(label: "Available", value: (viewModel.healthStatus?.defaultModelAvailable ?? false) ? "Yes" : "No")
                            LabeledValueRow(label: "Count", value: String(viewModel.healthStatus?.availableModels ?? 0))
                        }
                    }

                    if let modelNames = viewModel.healthStatus?.availableModelNames, !modelNames.isEmpty {
                        InfoCard(title: "Available Models") {
                            FlowLayout(items: modelNames) { modelName in
                                ModelBadge(title: modelName)
                            }
                        }
                    }

                    if let features = viewModel.serverInfo?.features, !features.isEmpty {
                        InfoCard(title: "Features") {
                            FlowLayout(items: features) { feature in
                                ModelBadge(title: feature)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}
