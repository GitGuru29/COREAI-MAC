import Foundation

final class DefaultSettingsStore: SettingsStore {
    private enum Keys {
        static let baseURL = "settings.baseURL"
        static let preferredModel = "settings.preferredModel"
        static let streamingEnabledByDefault = "settings.streamingEnabledByDefault"
        static let automaticModelRoutingEnabled = "settings.automaticModelRoutingEnabled"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        registerDefaults()
    }

    func loadSettings() -> AppSettings {
        AppSettings(
            baseURL: userDefaults.string(forKey: Keys.baseURL) ?? AppSettings.defaultBaseURL,
            preferredModel: userDefaults.string(forKey: Keys.preferredModel) ?? AppSettings.defaultPreferredModel,
            streamingEnabledByDefault: userDefaults.object(forKey: Keys.streamingEnabledByDefault) as? Bool ?? AppSettings.defaultStreamingEnabledByDefault,
            automaticModelRoutingEnabled: userDefaults.object(forKey: Keys.automaticModelRoutingEnabled) as? Bool ?? AppSettings.defaultAutomaticModelRoutingEnabled
        )
    }

    func saveBaseURL(_ value: String) {
        userDefaults.set(value, forKey: Keys.baseURL)
    }

    func savePreferredModel(_ value: String) {
        userDefaults.set(value, forKey: Keys.preferredModel)
    }

    func saveStreamingEnabledByDefault(_ value: Bool) {
        userDefaults.set(value, forKey: Keys.streamingEnabledByDefault)
    }

    func saveAutomaticModelRoutingEnabled(_ value: Bool) {
        userDefaults.set(value, forKey: Keys.automaticModelRoutingEnabled)
    }

    private func registerDefaults() {
        userDefaults.register(defaults: [
            Keys.baseURL: AppSettings.defaultBaseURL,
            Keys.preferredModel: AppSettings.defaultPreferredModel,
            Keys.streamingEnabledByDefault: AppSettings.defaultStreamingEnabledByDefault,
            Keys.automaticModelRoutingEnabled: AppSettings.defaultAutomaticModelRoutingEnabled
        ])
    }
}
