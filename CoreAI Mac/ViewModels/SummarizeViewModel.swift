import Combine
import Foundation

@MainActor
final class SummarizeViewModel: ObservableObject {
    @Published var sourceText = ""
    @Published var selectedModel: String
    @Published var style = "brief"
    @Published var outputText = ""
    @Published var isRunning = false
    @Published var isStreaming = false
    @Published var errorMessage: String?
    @Published var lastModel = ""
    @Published var lastCreatedAt = ""
    @Published var elapsedSeconds = 0
    @Published var availableModels: [ModelInfo] = []

    private let coreAIService: CoreAIService
    private let settingsStore: SettingsStore
    private var streamTask: Task<Void, Never>?
    private var elapsedTask: Task<Void, Never>?

    init(coreAIService: CoreAIService, settingsStore: SettingsStore) {
        self.coreAIService = coreAIService
        self.settingsStore = settingsStore
        self.selectedModel = settingsStore.loadSettings().preferredModel
    }

    func load() async {
        await refreshModels()
    }

    func refreshModels() async {
        do {
            let response = try await coreAIService.fetchModels()
            availableModels = response.models

            if !availableModels.contains(where: { $0.name == selectedModel }) {
                selectedModel = availableModels.first?.name ?? settingsStore.loadSettings().preferredModel
            }
        } catch {
            // Silently ignore errors for background refresh
        }
    }

    var characterCount: Int { sourceText.count }

    var canSubmit: Bool {
        !isRunning && !sourceText.trimmed.isEmpty && !selectedModel.trimmed.isEmpty
    }

    func cancel() {
        streamTask?.cancel()
        stopElapsedTimer()
        isRunning = false
        isStreaming = false
        errorMessage = "Request cancelled."
    }

    func run() {
        guard canSubmit else { return }

        let request = SummarizeRequest(
            text: sourceText.trimmed,
            style: style,
            model: selectedModel,
            temperature: 0.2,
            keepAlive: "5m"
        )

        errorMessage = nil
        isRunning = true
        outputText = ""
        lastModel = ""
        lastCreatedAt = ""
        startElapsedTimer()

        let prefersStreaming = settingsStore.loadSettings().streamingEnabledByDefault
        if prefersStreaming {
            isStreaming = true
            let previousOutput = outputText
            streamTask = Task {
                do {
                    let stream = try coreAIService.streamSummarize(request)
                    for try await event in stream {
                        outputText += event.chunk
                        lastModel = event.model
                        if let createdAt = event.createdAt {
                            lastCreatedAt = ISO8601DateFormatter.shared.displayString(from: createdAt) ?? createdAt
                        }
                        if event.done {
                            break
                        }
                    }
                    finishRun()
                } catch is CancellationError {
                    finishRun(cancelled: true)
                } catch {
                    if outputText.isEmpty {
                        outputText = previousOutput
                    }
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    finishRun()
                }
            }
        } else {
            isStreaming = false
            streamTask = Task {
                do {
                    let response = try await coreAIService.summarize(request)
                    outputText = response.outputText
                    lastModel = response.model
                    if let createdAt = response.createdAt {
                        lastCreatedAt = ISO8601DateFormatter.shared.displayString(from: createdAt) ?? createdAt
                    }
                    finishRun()
                } catch {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    finishRun()
                }
            }
        }
    }

    private func startElapsedTimer() {
        elapsedSeconds = 0
        elapsedTask?.cancel()
        elapsedTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.elapsedSeconds += 1
                }
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTask?.cancel()
        elapsedTask = nil
    }

    private func finishRun(cancelled: Bool = false) {
        streamTask = nil
        stopElapsedTimer()
        isRunning = false
        isStreaming = false

        if cancelled {
            return
        }
    }
}
