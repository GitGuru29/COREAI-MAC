import Foundation

struct ConnectionMonitorSnapshot {
    let state: ConnectionMonitorState
    let message: String
    let retryInterval: TimeInterval?
    let lastSuccessDate: Date?

    static let idle = ConnectionMonitorSnapshot(
        state: .idle,
        message: "Waiting to check backend availability.",
        retryInterval: nil,
        lastSuccessDate: nil
    )
}

enum ConnectionMonitorState {
    case idle
    case checking
    case connected
    case reconnecting
    case disconnected
}
