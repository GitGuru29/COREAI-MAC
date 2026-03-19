import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var healthStatus: HealthStatus?
    @Published var serverInfo: ServerInfo?
    @Published var connectionSnapshot: ConnectionMonitorSnapshot = .idle
    @Published var baseURL = AppSettings.defaultBaseURL
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let coreAIService: CoreAIService
    private let settingsStore: SettingsStore
    private var cancellables: Set<AnyCancellable> = []

    init(
        coreAIService: CoreAIService,
        settingsStore: SettingsStore,
        connectionMonitorService: ConnectionMonitorService
    ) {
        self.coreAIService = coreAIService
        self.settingsStore = settingsStore
        baseURL = settingsStore.loadSettings().baseURL
        connectionMonitorService.snapshotPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.connectionSnapshot = snapshot
            }
            .store(in: &cancellables)
    }

    func load() async {
        if healthStatus == nil && serverInfo == nil {
            await refresh()
        }
    }

    func refresh() async {
        baseURL = settingsStore.loadSettings().baseURL
        isLoading = true
        errorMessage = nil

        do {
            async let health = coreAIService.fetchHealth()
            async let info = coreAIService.fetchInfo()
            healthStatus = try await health
            serverInfo = try await info
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    var bannerStyle: ConnectionBannerStyle {
        switch connectionSnapshot.state {
        case .connected:
            if let healthStatus {
                return healthStatus.isHealthy ? .healthy : .warning
            }
            return .healthy
        case .checking, .reconnecting, .idle:
            return .warning
        case .disconnected:
            return .failed
        }
    }

    var bannerTitle: String {
        switch connectionSnapshot.state {
        case .connected:
            if let healthStatus {
                return healthStatus.isHealthy ? "Connected" : "Connected With Warnings"
            }
            return "Connected"
        case .checking:
            return "Checking Connection"
        case .reconnecting:
            return "Reconnecting"
        case .disconnected:
            return "Connection Failed"
        case .idle:
            return "Waiting To Check"
        }
    }

    var bannerMessage: String {
        if connectionSnapshot.state == .disconnected || connectionSnapshot.state == .reconnecting {
            return connectionSnapshot.message
        }
        if let errorMessage {
            return errorMessage
        }
        if let healthStatus {
            return "Service: \(healthStatus.service) • Ollama: \(healthStatus.ollamaStatus)"
        }
        return connectionSnapshot.message
    }
}
