import Foundation

extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    func displayString(from value: String) -> String? {
        if let date = date(from: value) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }

        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        guard let fallbackDate = fallbackFormatter.date(from: value) else {
            return nil
        }

        return fallbackDate.formatted(date: .abbreviated, time: .shortened)
    }
}
