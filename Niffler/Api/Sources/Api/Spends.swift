import Foundation

public struct Spends: Identifiable, Encodable {
    public let id: String
    public let spendDate: String
    public let category: String
    public let currency: String
    public let amount: Double
    public let description: String
    public let username: String
    
    public func toDictionaryWithoutId() -> [String: Any] {
        return [
            "spendDate": spendDate,
            "category": category,
            "currency": currency,
            "amount": amount,
            "description": description,
            "username": username
        ]
    }
}
