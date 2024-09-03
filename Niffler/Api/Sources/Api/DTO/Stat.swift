import Foundation
import SwiftUI

public struct Stat {
    public let currency: String
    public let total: Int
    public let statByCategories: [StatByCategories]

    public init(currency: String, total: Int, statByCategories: [StatByCategories]) {
        self.currency = currency
        self.total = total
        self.statByCategories = statByCategories
    }
}

public struct StatByCategories: Identifiable {
    public let id: UUID
    public let categoryName: String
    public let currency: String
    public let firstSpendDate: Date
    public let lastSpendDate: Date
    public let sum: Double
    public let color: Color
    
    public init(categoryName: String, currency: String, firstSpendDate: Date, lastSpendDate: Date, sum: Double) {
        self.id = UUID()
        self.categoryName = categoryName
        self.currency = currency
        self.firstSpendDate = firstSpendDate
        self.lastSpendDate = lastSpendDate
        self.sum = sum
        self.color = .random
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1)
        )
    }
}
