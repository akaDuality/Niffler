import Foundation

public class DateFormatterHelper {
    
    public static var shared: DateFormatterHelper = {
       DateFormatterHelper()
    }()
    
    public let dateFormatterFromApi: DateFormatter
    public let dateFormatterToApi: DateFormatter
    
    private let dateFormatterForUser: DateFormatter
    
    private init() {
        dateFormatterFromApi = DateFormatter()
        dateFormatterFromApi.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        dateFormatterForUser = DateFormatter()
        dateFormatterForUser.dateFormat = "dd MMM yy"
        
        dateFormatterToApi = DateFormatter()
        dateFormatterToApi.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }

    public func formatForUser(_ date: Date) -> String {
        dateFormatterForUser.string(from: date)
    }
}
