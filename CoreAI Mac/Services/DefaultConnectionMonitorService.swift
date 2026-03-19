import AppKit
import Combine
import Foundation

@MainActor
final class DefaultConnectionMonitorService: ConnectionMonitorService {
    var snapshotPublisher: AnyPublisher<ConnectionMonitorSnapshot, Never> {
        $snapshot.eraseToAnyPublisher()
    }

    @Published private var snapshot: ConnectionMonitorSnapshot = .idle

    private let coreAIService: CoreAIService
    private var monitorTask: Task<Void, Never>?
    private var wakeObserver: NSObjectProtocol?
    private var retryImmediately = false

    init(coreAIService: CoreAIService) {
        self.coreAIService = coreAIService
    }

    func start() {
        guard monitorTask == nil else { return }

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reconnectSoon()
        }

        monitorTask = Task { [weak self] in
            guard let self else { return }
            await self.runLoop()
        }
    }

    func reconnectSoon() {
        retryImmediately = true
    }

    func stop() {
        monitorTask?.cancel()
        monitorTask = nil

        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            self.wakeObserver = nil
        }
    }

    private func runLoop() async {
        var failureCount = 0

        while !Task.isCancelled {
            let isReconnect = failureCount > 0
            snapshot = ConnectionMonitorSnapshot(
                state: isReconnect ? .reconnecting : .checking,
                message: isReconnect ? "Attempting to reconnect to coreai-local.local…" : "Checking connection to coreai-local.local…",
                retryInterval: nil,
                lastSuccessDate: snapshot.lastSuccessDate
            )

            do {
                _ = try await coreAIService.fetchHealth()
                failureCount = 0
                retryImmediately = false
                snapshot = ConnectionMonitorSnapshot(
                    state: .connected,
                    message: "Connected to coreai-local.local.",
                    retryInterval: nil,
                    lastSuccessDate: .now
                )
                try? await Task.sleep(nanoseconds: 30_000_000_000)
            } catch {
                failureCount += 1
                let retryInterval = min(pow(2.0, Double(failureCount - 1)) * 5.0, 60.0)
                snapshot = ConnectionMonitorSnapshot(
                    state: .disconnected,
                    message: "Unable to reach coreai-local.local. The app will retry automatically.",
                    retryInterval: retryInterval,
                    lastSuccessDate: snapshot.lastSuccessDate
                )

                if retryImmediately {
                    retryImmediately = false
                    continue
                }

                try? await Task.sleep(nanoseconds: UInt64(retryInterval * 1_000_000_000))

                if retryImmediately {
                    retryImmediately = false
                }
            }
        }
    }
}
