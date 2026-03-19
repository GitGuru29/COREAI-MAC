import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: ChatMessageRole
    var text: String
    var state: ChatMessageState
    var createdAt: Date
    var metadata: ChatMessageMetadata?

    init(
        id: UUID = UUID(),
        role: ChatMessageRole,
        text: String,
        state: ChatMessageState = .completed,
        createdAt: Date = .now,
        metadata: ChatMessageMetadata? = nil
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.state = state
        self.createdAt = createdAt
        self.metadata = metadata
    }
}

enum ChatMessageRole: Equatable {
    case user
    case assistant
}

enum ChatMessageState: Equatable {
    case loading
    case streaming
    case completed
    case error(String)
}

struct ChatMessageMetadata: Equatable {
    let model: String
    let createdAtText: String
    let totalDurationText: String
    let evalCountText: String

    init(response: ChatResponse) {
        self.model = response.model
        self.createdAtText = ISO8601DateFormatter.shared.displayString(from: response.createdAt) ?? response.createdAt
        self.totalDurationText = DurationFormatter.displayString(fromNanoseconds: response.totalDuration)
        self.evalCountText = response.evalCount.map(String.init) ?? "n/a"
    }
}
