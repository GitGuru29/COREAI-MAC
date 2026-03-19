import Foundation

enum AppRoute: String, CaseIterable, Identifiable, Hashable {
    case dashboard
    case models
    case chat
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .models:
            return "Models"
        case .chat:
            return "Chat"
        case .settings:
            return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:
            return "square.grid.2x2"
        case .models:
            return "shippingbox"
        case .chat:
            return "message"
        case .settings:
            return "gearshape"
        }
    }
}
