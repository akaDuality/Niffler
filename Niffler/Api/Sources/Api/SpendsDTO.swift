import Foundation

public struct SpendsDTO: Identifiable, Decodable {
    public let id: String
    public let spendDate: Date?
    public let category: String
    public let currency: String
    public let amount: Double
    public let description: String
    public let username: String
}
