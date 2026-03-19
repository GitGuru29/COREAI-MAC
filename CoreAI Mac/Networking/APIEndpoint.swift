import Foundation

struct APIEndpoint<Response: Decodable> {
    let path: String
    let method: HTTPMethod
    let requiresAuth: Bool
    let body: Data?
}

extension APIEndpoint where Response == HealthStatus {
    static let health = APIEndpoint(path: "/health", method: .get, requiresAuth: false, body: nil)
}

extension APIEndpoint where Response == ServerInfo {
    static let info = APIEndpoint(path: "/info", method: .get, requiresAuth: false, body: nil)
}

extension APIEndpoint where Response == ModelListResponse {
    static let models = APIEndpoint(path: "/models", method: .get, requiresAuth: true, body: nil)
}

extension APIEndpoint where Response == ChatResponse {
    static func chat(body: Data) -> APIEndpoint<ChatResponse> {
        APIEndpoint(path: "/chat", method: .post, requiresAuth: true, body: body)
    }
}
