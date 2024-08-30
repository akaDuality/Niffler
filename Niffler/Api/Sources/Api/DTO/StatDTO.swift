import Foundation

public struct StatDTO: Decodable {    
    public let currency: String
    public let total: Int
    public let statByCategories: [StatByCategoriesDTO]
    
    public struct StatByCategoriesDTO: Decodable {
        public let categoryName: String
        public let currency: String
        public let firstSpendDate: Date
        public let lastSpendDate: Date
        public let sum: Double
        
        public init(categoryName: String, currency: String, firstSpendDate: Date, lastSpendDate: Date, sum: Double) {
            self.categoryName = categoryName
            self.currency = currency
            self.firstSpendDate = firstSpendDate
            self.lastSpendDate = lastSpendDate
            self.sum = sum
        }
    }
    
    public init(currency: String, total: Int, statByCategories: [StatByCategoriesDTO]) {
        self.currency = currency
        self.total = total
        self.statByCategories = statByCategories
    }
}
