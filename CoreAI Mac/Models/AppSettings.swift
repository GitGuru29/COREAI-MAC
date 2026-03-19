import Foundation

struct AppSettings {
    static let defaultBaseURL = "https://coreai-local.local"
    static let defaultPreferredModel = "qwen2.5-coder:7b"
    static let defaultStreamingEnabledByDefault = true
    static let defaultAutomaticModelRoutingEnabled = true

    var baseURL: String
    var preferredModel: String
    var streamingEnabledByDefault: Bool
    var automaticModelRoutingEnabled: Bool

    static let `default` = AppSettings(
        baseURL: defaultBaseURL,
        preferredModel: defaultPreferredModel,
        streamingEnabledByDefault: defaultStreamingEnabledByDefault,
        automaticModelRoutingEnabled: defaultAutomaticModelRoutingEnabled
    )
}
