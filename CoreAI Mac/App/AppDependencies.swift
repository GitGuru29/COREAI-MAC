import Combine
import Foundation

@MainActor
final class AppDependencies: ObservableObject {
    let keychainService: KeychainService
    let settingsStore: SettingsStore
    let apiClient: APIClient
    let coreAIService: CoreAIService
    let connectionMonitorService: ConnectionMonitorService

    init() {
        let keychainService = DefaultKeychainService()
        let settingsStore = DefaultSettingsStore()
        let apiClient = APIClient(
            settingsStore: settingsStore,
            keychainService: keychainService
        )

        self.keychainService = keychainService
        self.settingsStore = settingsStore
        self.apiClient = apiClient
        let coreAIService = DefaultCoreAIService(apiClient: apiClient)
        self.coreAIService = coreAIService
        self.connectionMonitorService = DefaultConnectionMonitorService(coreAIService: coreAIService)
    }
}
