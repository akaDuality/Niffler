import Api
import SwiftUI

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

struct SpendsView: View {
    @EnvironmentObject var api: Api
    
    @StateObject var spendsRepository: SpendsRepository // StateObject allows to 
    
    @State var screenState: ScreenState = .loading
    @State var statByCategories: [StatByCategories] = []
    @State var totalStat: Int = .zero
    
    enum ScreenState {
        case loading
        case data([Spends])
        case error(String)
    }
    
    func fetchData() async {
        do {
            screenState = .loading
            
            let (spendsDto, _) = try await api.getSpends()
            let spendsModel = spendsDto.content.map { Spends(dto: $0) }
            spendsRepository.replace(spendsModel)
            
            let (statData, _) = try await api.getStat()
            let stat = Stat(from: statData)
            self.totalStat = stat.total
            self.statByCategories = stat.statByCategories
            
            screenState = .data(spendsRepository.sortedSpends)
        } catch {
            screenState = .error("Не смогли получить список трат")
        }
    }
}

extension SpendsView {
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                switch screenState {
                case .loading:
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    
                case .data(let spends):
                    LazyVStack {
                        StatisticView(statByCategories: $statByCategories, totalStat: $totalStat)
                        
                        ForEach(spendsRepository.sortedSpends) { spend in
                            NavigationLink(value: spend) {
                                SpendCard(spend: spend)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
                    }
                case .error(let errorText):
                    Text(errorText)
                    Button("Reload") {
                        Task {
                            await fetchData()
                        }
                    }
                }
            }
            .navigationDestination(for: Spends.self) { spend in
                DetailSpendView(spendsRepository: spendsRepository,
                                onAddSpend: {
                    // TODO: Edit spend
                }, editSpendView: spend)
            }
            .onAppear {
                // TODO: Restore check?
//                if screenState != .loading {
                    Task {
                        await fetchData()
                    }
//                }
            }
            .refreshable {
                Task {
                    await fetchData()
                }
            }
        }
    }

}

#Preview {
    ContentView()
}

let preveiwSpends: [Spends] = [
    Spends(
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "test", archived: false),
        currency: "RUB",
        amount: 180,
        description: "Test Spend",
        username: "stage"
    ),
    Spends(
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "test", archived: false),
        currency: "RUB",
        amount: 120,
        description: "Test Spend",
        username: "stage"
    ),
    Spends(
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "test", archived: false),
        currency: "RUB",
        amount: 500,
        description: "Test Spend",
        username: "stage"
    ),
]
