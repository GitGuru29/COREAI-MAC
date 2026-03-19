import Foundation

struct ChatRequest: Codable, Sendable {
    let prompt: String?
    let messages: [ChatConversationMessage]?
    let responseMode: ChatResponseMode?
    let model: String
    let systemPrompt: String?
    let temperature: Double
    let keepAlive: String

    enum CodingKeys: String, CodingKey {
        case prompt
        case messages
        case responseMode = "response_mode"
        case model
        case systemPrompt = "system_prompt"
        case temperature
        case keepAlive = "keep_alive"
    }
}

struct ChatConversationMessage: Codable, Equatable, Sendable {
    let role: ChatConversationRole
    let content: String
}

enum ChatConversationRole: String, Codable, Sendable {
    case system
    case user
    case assistant
}

enum ChatResponseMode: String, Codable, Sendable {
    case auto
    case guide
    case code
}
