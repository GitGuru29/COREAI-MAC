import Combine
import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    @Published var selectedRoute: AppRoute? = .dashboard
    @Published var requiresInitialSettings = false
    @Published var configurationMessage = ""

    private let settingsStore: SettingsStore
    private let keychainService: KeychainService

    init(settingsStore: SettingsStore, keychainService: KeychainService) {
        self.settingsStore = settingsStore
        self.keychainService = keychainService
    }

    func refreshConfigurationState() {
        let settings = settingsStore.loadSettings()
        let apiKey: String?

        do {
            apiKey = try keychainService.readAPIKey()
        } catch {
            apiKey = nil
        }

        let missingBaseURL = settings.baseURL.trimmed.isEmpty
        let missingAPIKey = apiKey?.trimmed.isEmpty ?? true
        requiresInitialSettings = missingBaseURL || missingAPIKey

        if requiresInitialSettings {
            selectedRoute = .settings
            configurationMessage = "Complete Settings before using protected endpoints."
        } else {
            configurationMessage = ""
        }
    }
}
