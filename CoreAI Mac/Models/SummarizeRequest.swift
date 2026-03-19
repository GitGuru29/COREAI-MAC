import Foundation

struct SummarizeRequest: Codable, Sendable {
    let text: String
    let style: String
    let model: String
    let temperature: Double
    let keepAlive: String

    enum CodingKeys: String, CodingKey {
        case text
        case style
        case model
        case temperature
        case keepAlive = "keep_alive"
    }
}
