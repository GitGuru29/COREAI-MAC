import SwiftUI

enum ConnectionBannerStyle {
    case healthy
    case warning
    case failed

    var tint: Color {
        switch self {
        case .healthy:
            return .green
        case .warning:
            return .orange
        case .failed:
            return .red
        }
    }

    var systemImage: String {
        switch self {
        case .healthy:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .failed:
            return "xmark.octagon.fill"
        }
    }
}

struct ConnectionBanner: View {
    let style: ConnectionBannerStyle
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: style.systemImage)
                .foregroundStyle(style.tint)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(style.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(style.tint.opacity(0.25), lineWidth: 1)
        )
    }
}
