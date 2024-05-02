import Foundation

extension Spends {
    public init(
        dto: SpendsContentDTO
    ) {
        self.id = dto.id
        self.spendDate = dto.spendDate
        self.category = dto.category
        self.currency = dto.currency
        self.amount = dto.amount
        self.description = dto.description
        self.username = dto.username
    }
}
