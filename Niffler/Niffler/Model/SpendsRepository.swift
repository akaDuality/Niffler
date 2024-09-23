import Foundation
import Api

class SpendsRepository: ObservableObject {
    
    private(set) var spends: [Spends] = [] {
        didSet {
            sortedSpends = sortedByDateDesc(spends)
        }
    }
    
    @Published private(set) var sortedSpends: [Spends] = []
    
    func add(_ spend: Spends) {
        spends.append(spend)
    }
    
    func replace(_ spends: [Spends]) {
        self.spends = spends
    }
    
    private func sortedByDateDesc(_ spends: [Spends]) -> [Spends] {
        return spends.sorted { $0.dateForSort > $1.dateForSort }
    }
}


