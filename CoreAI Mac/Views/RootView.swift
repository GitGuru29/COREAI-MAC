import SwiftUI

struct RootView: View {
    @StateObject private var rootViewModel: RootViewModel
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var modelsViewModel: ModelsViewModel
    @StateObject private var chatViewModel: ChatViewModel
    @StateObject private var summarizeViewModel: SummarizeViewModel
    @StateObject private var analyzeCodeViewModel: AnalyzeCodeViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    private let connectionMonitorService: ConnectionMonitorService

    init(dependencies: AppDependencies) {
        connectionMonitorService = dependencies.connectionMonitorService
        _rootViewModel = StateObject(
            wrappedValue: RootViewModel(
                settingsStore: dependencies.settingsStore,
                keychainService: dependencies.keychainService
            )
        )
        _dashboardViewModel = StateObject(
            wrappedValue: DashboardViewModel(
                coreAIService: dependencies.coreAIService,
                settingsStore: dependencies.settingsStore,
                connectionMonitorService: dependencies.connectionMonitorService
            )
        )
        _modelsViewModel = StateObject(
            wrappedValue: ModelsViewModel(
                coreAIService: dependencies.coreAIService,
                settingsStore: dependencies.settingsStore
            )
        )
        _chatViewModel = StateObject(
            wrappedValue: ChatViewModel(
                coreAIService: dependencies.coreAIService,
                settingsStore: dependencies.settingsStore
            )
        )
        _summarizeViewModel = StateObject(
            wrappedValue: SummarizeViewModel(
                coreAIService: dependencies.coreAIService,
                settingsStore: dependencies.settingsStore
            )
        )
        _analyzeCodeViewModel = StateObject(
            wrappedValue: AnalyzeCodeViewModel(
                coreAIService: dependencies.coreAIService,
                settingsStore: dependencies.settingsStore
            )
        )
        _settingsViewModel = StateObject(
            wrappedValue: SettingsViewModel(
                coreAIService: dependencies.coreAIService,
                settingsStore: dependencies.settingsStore,
                keychainService: dependencies.keychainService,
                connectionMonitorService: dependencies.connectionMonitorService
            )
        )
    }

    var body: some View {
        NavigationSplitView {
            PremiumSidebarView(
                selection: $rootViewModel.selectedRoute,
                requiresInitialSettings: rootViewModel.requiresInitialSettings
            )
        } detail: {
            VStack(spacing: 0) {
                if rootViewModel.requiresInitialSettings {
                    ConnectionBanner(
                        style: .warning,
                        title: "Settings Required",
                        message: rootViewModel.configurationMessage
                    )
                    .padding([.top, .horizontal])
                }

                Group {
                    switch rootViewModel.selectedRoute ?? .dashboard {
                    case .dashboard:
                        DashboardView(viewModel: dashboardViewModel)
                    case .models:
                        ModelsView(viewModel: modelsViewModel)
                    case .chat:
                        ChatView(viewModel: chatViewModel)
                    case .summarize:
                        SummarizeView(viewModel: summarizeViewModel)
                    case .analyzeCode:
                        AnalyzeCodeView(viewModel: analyzeCodeViewModel)
                    case .settings:
                        SettingsView(viewModel: settingsViewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 980, minHeight: 680)
        .task {
            rootViewModel.refreshConfigurationState()
            connectionMonitorService.start()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            rootViewModel.refreshConfigurationState()
        }
    }
}
