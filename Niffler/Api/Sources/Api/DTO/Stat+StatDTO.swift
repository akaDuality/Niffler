import Foundation

extension Stat {
    public init(from dto: StatDTO) {
        self.currency = dto.currency
        self.total = dto.total
        
        self.statByCategories = dto.statByCategories.map {
            StatByCategories(
                categoryName: $0.categoryName,
                currency: $0.currency,
                firstSpendDate: $0.firstSpendDate,
                lastSpendDate: $0.lastSpendDate,
                sum: $0.sum)
        }
    }
}
