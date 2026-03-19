import Foundation

struct ChatResponse: Codable, Sendable {
    let model: String
    let response: String
    let done: Bool
    let doneReason: String?
    let createdAt: String
    let totalDuration: Int64?
    let loadDuration: Int64?
    let promptEvalCount: Int?
    let evalCount: Int?
    let promptEvalDuration: Int64?
    let evalDuration: Int64?

    enum CodingKeys: String, CodingKey {
        case model
        case response
        case done
        case doneReason = "done_reason"
        case createdAt = "created_at"
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case evalCount = "eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalDuration = "eval_duration"
    }
}

struct ChatStreamEvent: Codable, Sendable {
    let model: String
    let chunk: String
    let done: Bool
    let doneReason: String?
    let createdAt: String?
    let totalDuration: Int64?
    let loadDuration: Int64?
    let promptEvalCount: Int?
    let evalCount: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case chunk
        case done
        case doneReason = "done_reason"
        case createdAt = "created_at"
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case evalCount = "eval_count"
    }
}
