import Foundation

struct ConnectionTestResult {
    let health: HealthStatus
    let info: ServerInfo
    let models: ModelListResponse?
}
