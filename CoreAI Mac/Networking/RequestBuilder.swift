import Foundation

struct RequestBuilder {
    static let requestTimeout: TimeInterval = 300

    let settingsStore: SettingsStore
    let keychainService: KeychainService

    func build<Response: Decodable>(for endpoint: APIEndpoint<Response>) throws -> URLRequest {
        let settings = settingsStore.loadSettings()
        let trimmedBaseURL = settings.baseURL.trimmed

        guard
            let baseURL = URL(string: trimmedBaseURL),
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            throw APIError.invalidBaseURL
        }

        components.path = endpoint.path

        guard let finalURL = components.url else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.timeoutInterval = Self.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if endpoint.requiresAuth {
            guard let apiKey = try keychainService.readAPIKey(), !apiKey.trimmed.isEmpty else {
                throw APIError.missingAPIKey
            }
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }

        return request
    }
}
