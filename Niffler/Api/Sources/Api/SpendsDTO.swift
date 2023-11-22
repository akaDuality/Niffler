import Foundation

struct Spends: Decodable {
    let id: String
    let spendDate: String
    let category: String
    let currency: String
    let amount: Double
    let description: String
    let username: String
}
