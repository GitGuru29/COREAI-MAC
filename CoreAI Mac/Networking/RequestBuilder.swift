import Foundation

struct RequestBuilder {
    static let requestTimeout: TimeInterval = 600  // 10 min — max idle time between chunks

    let settingsStore: SettingsStore
    let keychainService: KeychainService

    func build<Response: Decodable>(for endpoint: APIEndpoint<Response>) throws -> URLRequest {
        try buildRequest(
            path: endpoint.path,
            method: endpoint.method,
            requiresAuth: endpoint.requiresAuth,
            body: endpoint.body
        )
    }

    func build<Response: Decodable>(for endpoint: APIStreamingEndpoint<Response>) throws -> URLRequest {
        try buildRequest(
            path: endpoint.path,
            method: endpoint.method,
            requiresAuth: endpoint.requiresAuth,
            body: endpoint.body
        )
    }

    private func buildRequest(
        path: String,
        method: HTTPMethod,
        requiresAuth: Bool,
        body: Data?
    ) throws -> URLRequest {
        let settings = settingsStore.loadSettings()
        let trimmedBaseURL = settings.baseURL.trimmed

        guard
            let baseURL = URL(string: trimmedBaseURL),
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            throw APIError.invalidBaseURL
        }

        components.path = path

        guard let finalURL = components.url else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.timeoutInterval = Self.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if requiresAuth {
            guard let apiKey = try keychainService.readAPIKey(), !apiKey.trimmed.isEmpty else {
                throw APIError.missingAPIKey
            }
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }

        return request
    }
}
