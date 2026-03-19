import Foundation

struct AnalyzeCodeResponse: Codable, Sendable {
    let model: String
    let language: String?
    let task: String?
    let sourceLength: Int?
    let analysis: String?
    let response: String?
    let createdAt: String?
    let totalDuration: Int64?
    let loadDuration: Int64?
    let promptEvalCount: Int?
    let evalCount: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case language
        case task
        case sourceLength = "source_length"
        case analysis
        case response
        case createdAt = "created_at"
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case evalCount = "eval_count"
    }

    var outputText: String {
        analysis ?? response ?? ""
    }
}
