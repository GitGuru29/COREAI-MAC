import Foundation

struct APIStreamingEndpoint<Response: Decodable> {
    let path: String
    let method: HTTPMethod
    let requiresAuth: Bool
    let body: Data?
}

extension APIStreamingEndpoint where Response == ChatStreamEvent {
    static func chatStream(body: Data) -> APIStreamingEndpoint<ChatStreamEvent> {
        APIStreamingEndpoint(path: "/chat/stream", method: .post, requiresAuth: true, body: body)
    }
}

extension APIStreamingEndpoint where Response == SummarizeStreamEvent {
    static func summarizeStream(body: Data) -> APIStreamingEndpoint<SummarizeStreamEvent> {
        APIStreamingEndpoint(path: "/summarize/stream", method: .post, requiresAuth: true, body: body)
    }
}

extension APIStreamingEndpoint where Response == AnalyzeCodeStreamEvent {
    static func analyzeCodeStream(body: Data) -> APIStreamingEndpoint<AnalyzeCodeStreamEvent> {
        APIStreamingEndpoint(path: "/analyze-code/stream", method: .post, requiresAuth: true, body: body)
    }
}
