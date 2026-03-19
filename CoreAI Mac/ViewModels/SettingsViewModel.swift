import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var baseURL = AppSettings.defaultBaseURL
    @Published var apiKey = ""
    @Published var preferredModel = AppSettings.defaultPreferredModel
    @Published var streamingEnabledByDefault = AppSettings.defaultStreamingEnabledByDefault
    @Published var automaticModelRoutingEnabled = AppSettings.defaultAutomaticModelRoutingEnabled
    @Published var isTestingConnection = false
    @Published var isSaving = false
    @Published var testResult: ConnectionTestResult?
    @Published var testMessage: String?
    @Published var errorMessage: String?

    private let coreAIService: CoreAIService
    private let settingsStore: SettingsStore
    private let keychainService: KeychainService
    private let connectionMonitorService: ConnectionMonitorService

    init(
        coreAIService: CoreAIService,
        settingsStore: SettingsStore,
        keychainService: KeychainService,
        connectionMonitorService: ConnectionMonitorService
    ) {
        self.coreAIService = coreAIService
        self.settingsStore = settingsStore
        self.keychainService = keychainService
        self.connectionMonitorService = connectionMonitorService
        load()
    }

    func load() {
        let settings = settingsStore.loadSettings()
        baseURL = settings.baseURL
        preferredModel = settings.preferredModel
        streamingEnabledByDefault = settings.streamingEnabledByDefault
        automaticModelRoutingEnabled = settings.automaticModelRoutingEnabled
        do {
            apiKey = try keychainService.readAPIKey() ?? ""
        } catch {
            apiKey = ""
        }
    }

    func save() {
        isSaving = true
        errorMessage = nil

        do {
            try persistInputs()
            connectionMonitorService.reconnectSoon()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isSaving = false
    }

    func testConnection() async {
        isTestingConnection = true
        errorMessage = nil
        testMessage = nil
        testResult = nil

        do {
            try persistInputs()
            connectionMonitorService.reconnectSoon()
            let includeProtectedCheck = !apiKey.trimmed.isEmpty
            let result = try await coreAIService.testConnection(includeProtectedCheck: includeProtectedCheck)
            testResult = result

            if let models = result.models?.models.map(\.name), !models.isEmpty, !models.contains(preferredModel) {
                preferredModel = models.contains(AppSettings.defaultPreferredModel) ? AppSettings.defaultPreferredModel : models[0]
                settingsStore.savePreferredModel(preferredModel)
            }

            testMessage = includeProtectedCheck
                ? "Connection succeeded for public and protected endpoints."
                : "Connection succeeded for public endpoints."
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isTestingConnection = false
    }

    private func persistInputs() throws {
        settingsStore.saveBaseURL(baseURL.trimmed.isEmpty ? AppSettings.defaultBaseURL : baseURL.trimmed)
        settingsStore.savePreferredModel(preferredModel.trimmed.isEmpty ? AppSettings.defaultPreferredModel : preferredModel.trimmed)
        settingsStore.saveStreamingEnabledByDefault(streamingEnabledByDefault)
        settingsStore.saveAutomaticModelRoutingEnabled(automaticModelRoutingEnabled)

        if apiKey.trimmed.isEmpty {
            try keychainService.deleteAPIKey()
        } else {
            try keychainService.saveAPIKey(apiKey.trimmed)
        }
    }
}
