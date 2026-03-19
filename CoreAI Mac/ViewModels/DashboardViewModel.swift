import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var healthStatus: HealthStatus?
    @Published var serverInfo: ServerInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let coreAIService: CoreAIService

    init(coreAIService: CoreAIService) {
        self.coreAIService = coreAIService
    }

    func load() async {
        if healthStatus == nil && serverInfo == nil {
            await refresh()
        }
    }

    func refresh() async {
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
        if let healthStatus {
            return healthStatus.isHealthy ? .healthy : .warning
        }
        return errorMessage == nil ? .warning : .failed
    }

    var bannerTitle: String {
        if let healthStatus {
            return healthStatus.isHealthy ? "Connected" : "Connected With Warnings"
        }
        return errorMessage == nil ? "Checking Connection" : "Connection Failed"
    }

    var bannerMessage: String {
        if let errorMessage {
            return errorMessage
        }
        if let healthStatus {
            return "Service: \(healthStatus.service) • Ollama: \(healthStatus.ollamaStatus)"
        }
        return "Checking server health and configuration."
    }
}
