import Combine
import Foundation

@MainActor
final class ModelsViewModel: ObservableObject {
    @Published var models: [ModelInfo] = []
    @Published var preferredModel: String
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let coreAIService: CoreAIService
    private let settingsStore: SettingsStore

    init(coreAIService: CoreAIService, settingsStore: SettingsStore) {
        self.coreAIService = coreAIService
        self.settingsStore = settingsStore
        self.preferredModel = settingsStore.loadSettings().preferredModel
    }

    func load() async {
        if models.isEmpty {
            await refresh()
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await coreAIService.fetchModels()
            models = response.models
            applyPreferredModelFallbackIfNeeded()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    func selectPreferredModel(_ modelName: String) {
        preferredModel = modelName
        settingsStore.savePreferredModel(modelName)
    }

    private func applyPreferredModelFallbackIfNeeded() {
        guard !models.isEmpty else {
            return
        }

        if !models.contains(where: { $0.name == preferredModel }) {
            let fallback = models.first(where: { $0.name == AppSettings.defaultPreferredModel })?.name ?? models[0].name
            preferredModel = fallback
            settingsStore.savePreferredModel(fallback)
        }
    }
}
