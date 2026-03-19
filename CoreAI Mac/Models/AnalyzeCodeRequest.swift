import Foundation

struct AnalyzeCodeRequest: Codable, Sendable {
    let source: String
    let language: String
    let task: String
    let model: String
    let temperature: Double
    let keepAlive: String

    enum CodingKeys: String, CodingKey {
        case source
        case language
        case task
        case model
        case temperature
        case keepAlive = "keep_alive"
    }
}
