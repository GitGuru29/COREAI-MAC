import Combine
import Foundation

protocol ConnectionMonitorService {
    var snapshotPublisher: AnyPublisher<ConnectionMonitorSnapshot, Never> { get }
    func start()
    func reconnectSoon()
    func stop()
}
