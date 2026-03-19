import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var selectedModel: String
    @Published var systemPrompt = ""
    @Published var temperature = 0.2
    @Published var keepAlive = "5m"
    @Published var availableModels: [ModelInfo] = []
    @Published var response: ChatResponse?
    @Published var messages: [ChatMessage] = []
    @Published var isSending = false
    @Published var isLoadingModels = false
    @Published var errorMessage: String?
    @Published var maxPromptChars = 12_000

    private let coreAIService: CoreAIService
    private let settingsStore: SettingsStore

    init(coreAIService: CoreAIService, settingsStore: SettingsStore) {
        self.coreAIService = coreAIService
        self.settingsStore = settingsStore
        self.selectedModel = settingsStore.loadSettings().preferredModel
    }

    var characterCount: Int {
        prompt.count
    }

    var canSend: Bool {
        !isSending &&
        !prompt.trimmed.isEmpty &&
        characterCount <= maxPromptChars &&
        !selectedModel.trimmed.isEmpty
    }

    var hasConversation: Bool {
        !messages.isEmpty
    }

    func load() async {
        if availableModels.isEmpty {
            await refreshModels()
        }
    }

    func refreshModels() async {
        isLoadingModels = true
        errorMessage = nil

        do {
            async let modelsRequest = coreAIService.fetchModels()
            async let infoRequest = coreAIService.fetchInfo()
            let models = try await modelsRequest
            let info = try await infoRequest

            availableModels = models.models
            maxPromptChars = info.maxPromptChars

            if !availableModels.contains(where: { $0.name == selectedModel }) {
                selectedModel = availableModels.first?.name ?? settingsStore.loadSettings().preferredModel
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoadingModels = false
    }

    func send() async {
        let trimmedPrompt = prompt.trimmed

        guard !trimmedPrompt.isEmpty else {
            errorMessage = "Enter a prompt before sending."
            return
        }

        guard trimmedPrompt.count <= maxPromptChars else {
            errorMessage = "The prompt exceeded the maximum length of \(maxPromptChars) characters."
            return
        }

        isSending = true
        errorMessage = nil

        let assistantMessageID = UUID()
        messages.append(
            ChatMessage(
                role: .user,
                text: trimmedPrompt,
                state: .completed
            )
        )
        messages.append(
            ChatMessage(
                id: assistantMessageID,
                role: .assistant,
                text: "",
                state: .loading
            )
        )
        prompt = ""

        let request = ChatRequest(
            prompt: trimmedPrompt,
            model: selectedModel,
            systemPrompt: systemPrompt.trimmed.nilIfEmpty,
            temperature: temperature,
            keepAlive: keepAlive.trimmed.isEmpty ? "5m" : keepAlive.trimmed
        )

        do {
            let response = try await coreAIService.sendChat(request)
            self.response = response
            updateAssistantMessage(
                id: assistantMessageID,
                text: response.response,
                state: .completed,
                metadata: ChatMessageMetadata(response: response)
            )
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            updateAssistantMessage(
                id: assistantMessageID,
                text: message,
                state: .error(message),
                metadata: nil
            )
        }

        isSending = false
    }

    func updateStreamingText(_ text: String, for id: UUID) {
        updateAssistantMessage(
            id: id,
            text: text,
            state: .streaming,
            metadata: nil
        )
    }

    func clear() {
        prompt = ""
        systemPrompt = ""
        response = nil
        errorMessage = nil
    }

    func clearConversation() {
        messages.removeAll()
        response = nil
        errorMessage = nil
    }

    func persistSelectedModel() {
        settingsStore.savePreferredModel(selectedModel)
    }

    private func updateAssistantMessage(
        id: UUID,
        text: String,
        state: ChatMessageState,
        metadata: ChatMessageMetadata?
    ) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else {
            return
        }

        messages[index].text = text
        messages[index].state = state
        messages[index].metadata = metadata
    }
}
