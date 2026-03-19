import Foundation

struct ChatRequest: Codable, Sendable {
    let prompt: String
    let model: String
    let systemPrompt: String?
    let temperature: Double
    let keepAlive: String

    enum CodingKeys: String, CodingKey {
        case prompt
        case model
        case systemPrompt = "system_prompt"
        case temperature
        case keepAlive = "keep_alive"
    }
}
