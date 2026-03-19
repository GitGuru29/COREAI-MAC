import Foundation

struct ModelListResponse: Codable, Sendable {
    let count: Int
    let models: [ModelInfo]
}

struct ModelInfo: Codable, Identifiable, Hashable, Sendable {
    let name: String
    let size: Int64
    let digest: String
    let modifiedAt: String
    let details: ModelDetails

    var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name
        case size
        case digest
        case modifiedAt = "modified_at"
        case details
    }
}

struct ModelDetails: Codable, Hashable, Sendable {
    let parentModel: String
    let format: String
    let family: String
    let families: [String]
    let parameterSize: String
    let quantizationLevel: String

    enum CodingKeys: String, CodingKey {
        case parentModel = "parent_model"
        case format
        case family
        case families
        case parameterSize = "parameter_size"
        case quantizationLevel = "quantization_level"
    }
}
