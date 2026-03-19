import Foundation

enum DurationFormatter {
    static func displayString(fromNanoseconds value: Int64?) -> String {
        guard let value else {
            return "n/a"
        }

        let seconds = Double(value) / 1_000_000_000

        if seconds >= 1 {
            return String(format: "%.2fs", seconds)
        }

        let milliseconds = seconds * 1_000
        return String(format: "%.0fms", milliseconds)
    }
}
