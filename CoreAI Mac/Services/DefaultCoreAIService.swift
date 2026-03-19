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
