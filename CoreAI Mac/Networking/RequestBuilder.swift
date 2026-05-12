import Foundation

struct RequestBuilder {
    static let requestTimeout: TimeInterval = 1800  // 30 min — match Linux backend OLLAMA_TIMEOUT

    let settingsStore: SettingsStore
    let keychainService: KeychainService

    func build<Response: Decodable>(for endpoint: APIEndpoint<Response>) throws -> URLRequest {
        try buildRequest(
            path: endpoint.path,
            method: endpoint.method,
            requiresAuth: endpoint.requiresAuth,
            body: endpoint.body,
            isStreaming: false
        )
    }

    func build<Response: Decodable>(for endpoint: APIStreamingEndpoint<Response>) throws -> URLRequest {
        try buildRequest(
            path: endpoint.path,
            method: endpoint.method,
            requiresAuth: endpoint.requiresAuth,
            body: endpoint.body,
            isStreaming: true
        )
    }

    private func buildRequest(
        path: String,
        method: HTTPMethod,
        requiresAuth: Bool,
        body: Data?,
        isStreaming: Bool
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
        
        if isStreaming {
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            request.setValue("keep-alive", forHTTPHeaderField: "Connection")
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

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
