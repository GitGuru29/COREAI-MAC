import Foundation

protocol CoreAIService {
    func fetchHealth() async throws -> HealthStatus
    func fetchInfo() async throws -> ServerInfo
    func fetchModels() async throws -> ModelListResponse
    func sendChat(_ request: ChatRequest) async throws -> ChatResponse
    func testConnection(includeProtectedCheck: Bool) async throws -> ConnectionTestResult
}
