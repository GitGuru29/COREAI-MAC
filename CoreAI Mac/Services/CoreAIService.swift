import Foundation

protocol CoreAIService {
    func fetchHealth() async throws -> HealthStatus
    func fetchInfo() async throws -> ServerInfo
    func fetchModels() async throws -> ModelListResponse
    func sendChat(_ request: ChatRequest) async throws -> ChatResponse
    func streamChat(_ request: ChatRequest) throws -> AsyncThrowingStream<ChatStreamEvent, Error>
    func summarize(_ request: SummarizeRequest) async throws -> SummarizeResponse
    func streamSummarize(_ request: SummarizeRequest) throws -> AsyncThrowingStream<SummarizeStreamEvent, Error>
    func analyzeCode(_ request: AnalyzeCodeRequest) async throws -> AnalyzeCodeResponse
    func streamAnalyzeCode(_ request: AnalyzeCodeRequest) throws -> AsyncThrowingStream<AnalyzeCodeStreamEvent, Error>
    func testConnection(includeProtectedCheck: Bool) async throws -> ConnectionTestResult
}
