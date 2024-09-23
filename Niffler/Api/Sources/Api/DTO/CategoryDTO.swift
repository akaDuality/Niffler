import Foundation

public struct CategoryDTO: Identifiable, Codable, Hashable {
    public let id: String?
    public let name: String
    public let username: String?
    public let archived: Bool

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.archived = try container.decode(Bool.self, forKey: .archived)
    }

    public init(name: String, archived: Bool) {
        self.init(id: nil, name: name, username: nil, archived: archived)
    }
    
    public init(id: String?, name: String, username: String?, archived: Bool) {
        self.id = id
        self.name = name
        self.username = username
        self.archived = archived
    }
    
    public var isActive: Bool {
        !archived
    }
}
