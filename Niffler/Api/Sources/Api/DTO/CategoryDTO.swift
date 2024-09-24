import Foundation

public struct CategoryDTO: Identifiable, Codable, Hashable {
    public let id: String?
    public let name: String
    public let username: String?
    public let archived: Bool

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
