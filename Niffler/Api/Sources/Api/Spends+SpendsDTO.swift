import Foundation

extension Spends {
    public init(
        dto: SpendsDTO
    ) {
        self.id = dto.id
        if let dateDTO = dto.spendDate {
            self.spendDate = DateFormatterHelper().formatDateString(dateDTO)
        } else {
            self.spendDate = "NoData"
        }
        
        self.category = dto.category
        self.currency = dto.currency
        self.amount = dto.amount
        self.description = dto.description
        self.username = dto.username
    }
}
