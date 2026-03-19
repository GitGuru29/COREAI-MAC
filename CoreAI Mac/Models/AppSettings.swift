import Foundation

struct AppSettings {
    static let defaultBaseURL = "https://10.113.228.6"
    static let defaultPreferredModel = "qwen2.5-coder:7b"
    static let defaultStreamingEnabledByDefault = false

    var baseURL: String
    var preferredModel: String
    var streamingEnabledByDefault: Bool

    static let `default` = AppSettings(
        baseURL: defaultBaseURL,
        preferredModel: defaultPreferredModel,
        streamingEnabledByDefault: defaultStreamingEnabledByDefault
    )
}
