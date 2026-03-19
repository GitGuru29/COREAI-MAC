import Foundation

struct HealthStatus: Codable, Sendable {
    let status: String
    let service: String
    let version: String
    let serverMode: String
    let ollamaStatus: String
    let ollamaAvailable: Bool
    let defaultModel: String
    let ollamaBaseURL: String
    let ollamaVersion: String?
    let defaultModelAvailable: Bool
    let availableModels: Int
    let availableModelNames: [String]
    let detail: String?

    enum CodingKeys: String, CodingKey {
        case status
        case service
        case version
        case serverMode = "server_mode"
        case ollamaStatus = "ollama_status"
        case ollamaAvailable = "ollama_available"
        case defaultModel = "default_model"
        case ollamaBaseURL = "ollama_base_url"
        case ollamaVersion = "ollama_version"
        case defaultModelAvailable = "default_model_available"
        case availableModels = "available_models"
        case availableModelNames = "available_model_names"
        case detail
    }

    var isHealthy: Bool {
        status.lowercased() == "ok" && ollamaAvailable
    }
}
