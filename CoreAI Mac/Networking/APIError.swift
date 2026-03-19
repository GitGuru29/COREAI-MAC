import Foundation

enum APIError: LocalizedError {
    case invalidBaseURL
    case missingAPIKey
    case invalidResponse
    case decodingFailed
    case requestTimedOut
    case transportError(String)
    case serverError(statusCode: Int, backend: BackendErrorResponse?)
    case authenticationFailed(String)
    case validationError(String)
    case payloadTooLarge(String)
    case modelNotInstalled(message: String, requestedModel: String?, availableModels: [String])
    case rateLimited(String)
    case queueFull(String)
    case ollamaUnavailable(String)
    case ollamaTimeout(String)
    case internalServerError(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "The server base URL is invalid."
        case .missingAPIKey:
            return "The API key is missing. Add it in Settings."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed:
            return "The response could not be decoded."
        case .requestTimedOut:
            return "The request timed out after 5 minutes. The model host is responding too slowly for the current request."
        case .transportError(let message):
            return message
        case .serverError(_, let backend):
            return backend?.error ?? "The server returned an error."
        case .authenticationFailed(let message):
            return message
        case .validationError(let message):
            return message
        case .payloadTooLarge(let message):
            return message
        case .modelNotInstalled(let message, let requestedModel, let availableModels):
            var fragments = [message]
            if let requestedModel, !requestedModel.isEmpty {
                fragments.append("Requested model: \(requestedModel).")
            }
            if !availableModels.isEmpty {
                fragments.append("Available models: \(availableModels.joined(separator: ", ")).")
            }
            return fragments.joined(separator: " ")
        case .rateLimited(let message):
            return message
        case .queueFull(let message):
            return message
        case .ollamaUnavailable(let message):
            return message
        case .ollamaTimeout(let message):
            return message
        case .internalServerError(let message):
            return message
        }
    }

    static func map(statusCode: Int, backend: BackendErrorResponse?) -> APIError {
        let fallbackMessage = backend?.error ?? "The server returned an error."

        switch backend?.code {
        case "authentication_failed":
            return .authenticationFailed("The API key is missing or invalid.")
        case "validation_error":
            return .validationError(fallbackMessage)
        case "payload_too_large":
            return .payloadTooLarge("The prompt exceeded the server maximum length.")
        case "model_not_installed":
            let requestedModel = backend?.details?["requested_model"]?.stringValue
            let availableModels = backend?.details?["available_models"]?.arrayValue?.compactMap(\.stringValue) ?? []
            return .modelNotInstalled(
                message: fallbackMessage,
                requestedModel: requestedModel,
                availableModels: availableModels
            )
        case "rate_limited":
            return .rateLimited("Rate limit reached. Wait a moment and try again.")
        case "queue_full":
            return .queueFull("The server is busy and the request queue is full.")
        case "ollama_unavailable":
            return .ollamaUnavailable(fallbackMessage)
        case "ollama_timeout":
            return .ollamaTimeout(fallbackMessage)
        case "internal_server_error":
            return .internalServerError(fallbackMessage)
        default:
            return .serverError(statusCode: statusCode, backend: backend)
        }
    }
}
