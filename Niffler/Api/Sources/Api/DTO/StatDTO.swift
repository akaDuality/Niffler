import Foundation

public struct StatDTO: Decodable {    
    public let currency: String
    public let total: Int
    public let statByCategories: [StatByCategories]
    
    public struct StatByCategories: Identifiable, Decodable {
        public var id: UUID?
        
        public let categoryName: String
        public let currency: String
        public let firstSpendDate: Date
        public let lastSpendDate: Date
        public let sum: Double
    }
    
    public init(currency: String, total: Int, statByCategories: [StatByCategories]) {
        self.currency = currency
        self.total = total
        self.statByCategories = statByCategories
    }
}
