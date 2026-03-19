import Foundation

protocol SettingsStore {
    func loadSettings() -> AppSettings
    func saveBaseURL(_ value: String)
    func savePreferredModel(_ value: String)
    func saveStreamingEnabledByDefault(_ value: Bool)
}
