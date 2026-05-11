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
    @Published var automaticModelRoutingEnabled: Bool
    @Published var lastRoutingDecision: ModelRoutingDecision?
    @Published var canRetryLastRequest = false
    @Published var isSending = false
    @Published var isLoadingModels = false
    @Published var errorMessage: String?
    @Published var maxPromptChars = 12_000

    private let coreAIService: CoreAIService
    private let settingsStore: SettingsStore
    private var conversationHistory: [ChatConversationMessage] = []
    private var lastFailedContext: ChatFailureContext?

    init(coreAIService: CoreAIService, settingsStore: SettingsStore) {
        self.coreAIService = coreAIService
        self.settingsStore = settingsStore
        let settings = settingsStore.loadSettings()
        self.selectedModel = settings.preferredModel
        self.automaticModelRoutingEnabled = settings.automaticModelRoutingEnabled
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
        await refreshModels()
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
        let userMessageID = UUID()
        let priorHistory = conversationHistory
        let routingDecision = resolvedModel(for: trimmedPrompt)
        lastRoutingDecision = routingDecision
        let prefersStreaming = settingsStore.loadSettings().streamingEnabledByDefault
        let responseMode = ChatResponseModeResolver.resolve(
            prompt: trimmedPrompt,
            history: priorHistory
        )

        messages.append(
            ChatMessage(
                id: userMessageID,
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
            messages: priorHistory.isEmpty ? nil : priorHistory,
            responseMode: responseMode,
            model: routingDecision.model,
            systemPrompt: systemPrompt.trimmed.nilIfEmpty,
            temperature: temperature,
            keepAlive: keepAlive.trimmed.isEmpty ? "5m" : keepAlive.trimmed
        )
        let failureContext = ChatFailureContext(
            prompt: trimmedPrompt,
            priorHistory: priorHistory,
            userMessageID: userMessageID,
            assistantMessageID: assistantMessageID
        )

        if prefersStreaming {
            do {
                var fullText = ""
                let stream = try coreAIService.streamChat(request)
                for try await event in stream {
                    fullText += event.chunk
                    updateAssistantMessage(
                        id: assistantMessageID,
                        text: fullText,
                        state: event.done ? .completed : .streaming,
                        metadata: event.done ? ChatMessageMetadata(response: ChatResponse(
                            model: event.model,
                            response: fullText,
                            done: event.done,
                            doneReason: event.doneReason,
                            createdAt: event.createdAt ?? "",
                            totalDuration: event.totalDuration,
                            loadDuration: event.loadDuration,
                            promptEvalCount: event.promptEvalCount,
                            evalCount: event.evalCount,
                            promptEvalDuration: nil,
                            evalDuration: nil
                        )) : nil
                    )
                }
                finalizeSuccessfulConversation(
                    userPrompt: trimmedPrompt,
                    assistantText: messages.first(where: { $0.id == assistantMessageID })?.text ?? ""
                )
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                let partial = messages.first(where: { $0.id == assistantMessageID })?.text ?? ""
                updateAssistantMessage(
                    id: assistantMessageID,
                    text: partial.isEmpty ? message : partial,
                    state: .error(message),
                    metadata: nil
                )
                registerFailure(failureContext)
            }
        } else {
            do {
                let response = try await coreAIService.sendChat(request)
                self.response = response
                updateAssistantMessage(
                    id: assistantMessageID,
                    text: response.response,
                    state: .completed,
                    metadata: ChatMessageMetadata(response: response)
                )
                finalizeSuccessfulConversation(
                    userPrompt: trimmedPrompt,
                    assistantText: response.response
                )
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                updateAssistantMessage(
                    id: assistantMessageID,
                    text: message,
                    state: .error(message),
                    metadata: nil
                )
                registerFailure(failureContext)
            }
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
        conversationHistory.removeAll()
        lastFailedContext = nil
        canRetryLastRequest = false
    }

    func retryLastRequest() async {
        guard let failureContext = lastFailedContext, !isSending else {
            return
        }

        messages.removeAll {
            $0.id == failureContext.userMessageID || $0.id == failureContext.assistantMessageID
        }

        prompt = failureContext.prompt
        canRetryLastRequest = false
        lastFailedContext = nil
        await send()
    }

    func persistSelectedModel() {
        settingsStore.savePreferredModel(selectedModel)
    }

    func setAutomaticModelRoutingEnabled(_ enabled: Bool) {
        automaticModelRoutingEnabled = enabled
        settingsStore.saveAutomaticModelRoutingEnabled(enabled)
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

    private func resolvedModel(for prompt: String) -> ModelRoutingDecision {
        if automaticModelRoutingEnabled {
            return ModelRouter.decideModel(
                for: prompt,
                availableModels: availableModels,
                fallbackModel: selectedModel
            )
        }

        return ModelRoutingDecision(model: selectedModel, category: .general)
    }

    private func finalizeSuccessfulConversation(userPrompt: String, assistantText: String) {
        conversationHistory.append(
            ChatConversationMessage(role: .user, content: userPrompt)
        )
        conversationHistory.append(
            ChatConversationMessage(role: .assistant, content: assistantText)
        )
        lastFailedContext = nil
        canRetryLastRequest = false
    }

    private func registerFailure(_ context: ChatFailureContext) {
        lastFailedContext = context
        canRetryLastRequest = true
    }
}

private struct ChatFailureContext {
    let prompt: String
    let priorHistory: [ChatConversationMessage]
    let userMessageID: UUID
    let assistantMessageID: UUID
}
