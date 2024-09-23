import Foundation

public struct SpendsDTO: Decodable {
    public let content: [SpendsContentDTO]
}

public struct SpendsContentDTO: Identifiable, Codable {
    public let id: String
    public let spendDate: Date?
    public let category: CategoryDTO
    public let currency: String
    public let amount: Double
    public let description: String
    public let username: String
}

//    [
//        {
//            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//            "name": "string",
//            "username": "string",
//            "archived": true
//        }
//    ]
//public struct CategoryDto: Decodable {
//    let id: String
//    let name: String
//    let username: String
//    let archived: String
//}
