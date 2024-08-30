import Foundation

public struct Stat {
    public let currency: String
    public let total: Int
    public let statByCategories: [StatByCategories]
    
    public struct StatByCategories: Identifiable {
        public let id: UUID
        public let categoryName: String
        public let currency: String
        public let firstSpendDate: Date
        public let lastSpendDate: Date
        public let sum: Double
        
        public init(categoryName: String, currency: String, firstSpendDate: Date, lastSpendDate: Date, sum: Double) {
            self.id = UUID()
            self.categoryName = categoryName
            self.currency = currency
            self.firstSpendDate = firstSpendDate
            self.lastSpendDate = lastSpendDate
            self.sum = sum
        }
    }
    
    public init(currency: String, total: Int, statByCategories: [StatByCategories]) {
        self.currency = currency
        self.total = total
        self.statByCategories = statByCategories
    }
}
