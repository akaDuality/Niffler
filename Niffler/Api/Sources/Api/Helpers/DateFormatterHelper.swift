import Foundation

public class DateFormatterHelper {
    private let dateFormatterInput: DateFormatter
    private let dateFormatterOutput: DateFormatter

    public init() {
        dateFormatterInput = DateFormatter()
        dateFormatterInput.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        dateFormatterOutput = DateFormatter()
        dateFormatterOutput.dateFormat = "dd MMM yy"
    }

    func formatDateString(_ dateString: String) -> String {
        if let date = dateFormatterInput.date(from: dateString) {
            return dateFormatterOutput.string(from: date)
        } else {
            return "NoData"
        }
    }

    public func formatToApi(_ date: Date) -> String {
        dateFormatterInput.string(from: date)
    }

    public func formatForApiAddSpend(_ dateForm: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter.string(from: dateForm)
    }
}