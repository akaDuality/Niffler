import Api
import SwiftUI

struct SpendsView: View {
    @EnvironmentObject var api: Api
    
    @StateObject var spendsRepository: SpendsRepository // StateObject allows to 
    
    @State var screenState: ScreenState = .loading
    @State var statByCategories: [StatByCategories] = []
    @State var totalStat: Double = .zero
    
    enum ScreenState {
        case loading
        case data([Spends])
        case error(String)
    }
    
    func fetchData() async {
        do {
            screenState = .loading
            
            let (spendsDto, _) = try await api.getSpends()
            let spendsModel = spendsDto.content
            spendsRepository.replace(spendsModel)
            
            let (statData, _) = try await api.getStat()
            let stat = Stat(from: statData)
            self.totalStat = Double(stat.total)
            self.statByCategories = stat.statByCategories
            
            screenState = .data(spendsRepository.sortedSpends)
        } catch {
            screenState = .error("Не смогли получить список трат")
        }
    }
    
    @State private var isEdit: Bool = false
    @State private var selectedSpend: Spends?
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
                            SpendCell(spend: spend)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSpend = spend
                                    isEdit = true
                                }
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
            .navigationDestination(isPresented: $isEdit, destination: {
                if let selectedSpend {
                    DetailSpendView(spendsRepository: spendsRepository,
                                    onAddSpend: deselect,
                                    editSpendView: selectedSpend)
                } else {
                    EmptyView()
                }
            })
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
    
    func select(spend: Spends) {
        selectedSpend = spend
        isEdit = true
    }
    
    func deselect() {
        selectedSpend = nil
        isEdit = false
    }

}

#Preview {
    ContentView()
}

let preveiwSpends: [Spends] = [
    Spends(
        id: nil,
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "test", archived: false),
        currency: "RUB",
        amount: 180,
        description: "Test Spend",
        username: "stage"
    ),
    Spends(
        id: nil,
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "test", archived: false),
        currency: "RUB",
        amount: 120,
        description: "Test Spend",
        username: "stage"
    ),
    Spends(
        id: nil,
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "test", archived: false),
        currency: "RUB",
        amount: 500,
        description: "Test Spend",
        username: "stage"
    ),
]
