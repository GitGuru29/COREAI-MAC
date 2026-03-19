import Foundation

struct DefaultCoreAIService: CoreAIService {
    let apiClient: APIClient

    func fetchHealth() async throws -> HealthStatus {
        try await apiClient.send(.health)
    }

    func fetchInfo() async throws -> ServerInfo {
        try await apiClient.send(.info)
    }

    func fetchModels() async throws -> ModelListResponse {
        try await apiClient.send(.models)
    }

    func sendChat(_ request: ChatRequest) async throws -> ChatResponse {
        let body = try apiClient.encodeBody(request)
        return try await apiClient.send(.chat(body: body))
    }

    func streamChat(_ request: ChatRequest) throws -> AsyncThrowingStream<ChatStreamEvent, Error> {
        let body = try apiClient.encodeBody(request)
        return try apiClient.stream(.chatStream(body: body))
    }

    func summarize(_ request: SummarizeRequest) async throws -> SummarizeResponse {
        let body = try apiClient.encodeBody(request)
        return try await apiClient.send(.summarize(body: body))
    }

    func streamSummarize(_ request: SummarizeRequest) throws -> AsyncThrowingStream<SummarizeStreamEvent, Error> {
        let body = try apiClient.encodeBody(request)
        return try apiClient.stream(.summarizeStream(body: body))
    }

    func analyzeCode(_ request: AnalyzeCodeRequest) async throws -> AnalyzeCodeResponse {
        let body = try apiClient.encodeBody(request)
        return try await apiClient.send(.analyzeCode(body: body))
    }

    func streamAnalyzeCode(_ request: AnalyzeCodeRequest) throws -> AsyncThrowingStream<AnalyzeCodeStreamEvent, Error> {
        let body = try apiClient.encodeBody(request)
        return try apiClient.stream(.analyzeCodeStream(body: body))
    }

    func testConnection(includeProtectedCheck: Bool) async throws -> ConnectionTestResult {
        async let health = fetchHealth()
        async let info = fetchInfo()

        let healthValue = try await health
        let infoValue = try await info
        let modelsValue: ModelListResponse?
        if includeProtectedCheck {
            modelsValue = try await fetchModels()
        } else {
            modelsValue = nil
        }

        return ConnectionTestResult(
            health: healthValue,
            info: infoValue,
            models: modelsValue
        )
    }
}
