import Foundation

struct ServerInfo: Codable, Sendable {
    let service: String
    let version: String
    let environment: String
    let serverMode: String
    let offlineMode: Bool
    let apiHost: String
    let apiPort: Int
    let authEnabled: Bool
    let authExemptPaths: [String]
    let authHeaders: [String]
    let ollamaBaseURL: String
    let ollamaTimeout: Double
    let ollamaStatus: String
    let defaultModel: String
    let maxPromptChars: Int
    let availableModelNames: [String]
    let features: [String]
    let detail: String?

    enum CodingKeys: String, CodingKey {
        case service
        case version
        case environment
        case serverMode = "server_mode"
        case offlineMode = "offline_mode"
        case apiHost = "api_host"
        case apiPort = "api_port"
        case authEnabled = "auth_enabled"
        case authExemptPaths = "auth_exempt_paths"
        case authHeaders = "auth_headers"
        case ollamaBaseURL = "ollama_base_url"
        case ollamaTimeout = "ollama_timeout"
        case ollamaStatus = "ollama_status"
        case defaultModel = "default_model"
        case maxPromptChars = "max_prompt_chars"
        case availableModelNames = "available_model_names"
        case features
        case detail
    }
}
