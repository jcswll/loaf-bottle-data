import Foundation

extension DateFormatter {

    static let standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    static func dateString(from date: Date) -> String {
        let originalTimeStyle = self.standard.timeStyle
        self.standard.timeStyle = .none
        defer { self.standard.timeStyle = originalTimeStyle }

        return self.standard.string(from: date)
    }
}
