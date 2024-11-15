import Foundation

public class SpendsRepository: ObservableObject {
    
    @Published
    public private(set) var sortedSpends: [Spends] = []
    public init(api: Api) {
        self.api = api
    }
    
    private let api: Api
    
    public func fetch() async throws {
        let (spendsDto, _) = try await api.getSpends()
        let spendsModel = spendsDto.content
        replace(spendsModel)
    }
    
    private(set) var spends: [Spends] = [] {
        didSet {
            Task {
                await MainActor.run {
                    sortedSpends = sortedByDateDesc(spends)
                }
            }
        }
    }
    
    public func add(_ spend: Spends) {
        spends.append(spend)
    }
    
    public func replace(_ spends: [Spends]) {
        self.spends = spends
    }
    
    public func replace(_ spend: Spends) {
        guard let index = spends.firstIndex(where: { aSpend in
            aSpend.id == spend.id
        }) else {
            assertionFailure("Try to replace item that doesn't exists")
            return
        }
        
        spends[index] = spend
    }
    
    private func sortedByDateDesc(_ spends: [Spends]) -> [Spends] {
        return spends.sorted { $0.dateForSort > $1.dateForSort }
    }
}


