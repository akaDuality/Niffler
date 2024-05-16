import Foundation

public struct Spends: Identifiable, Encodable, Hashable {
    public let id: String?
    public let spendDate: Date?
    public let category: String
    public let currency: String
    public let amount: Double
    public let description: String
    public let username: String

    enum CodingKeys: CodingKey {
        case spendDate
        case category
        case currency
        case amount
        case description
        case username
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(spendDate, forKey: .spendDate)
        try container.encode(category, forKey: .category)
        try container.encode(currency, forKey: .currency)
        try container.encode(amount, forKey: .amount)
        try container.encode(description, forKey: .description)
        try container.encode(username, forKey: .username)
    }
}

// without id
extension Spends {
    public var dateForSort: Date {
        spendDate ?? .now
    }
    
    public init(
        spendDate: Date,
        category: String,
        currency: String,
        amount: Double,
        description: String,
        username: String
    ) {
        id = nil
        self.spendDate = spendDate
        self.category = category
        self.currency = currency
        self.amount = amount
        self.description = description
        self.username = username
    }
}


public func sortedByDateDesc(_ spends: [Spends]) -> [Spends] {
    return spends.sorted { $0.dateForSort > $1.dateForSort }
}
