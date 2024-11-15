import Api
import SwiftUI

struct SpendsView: View {
    @EnvironmentObject var api: Api
    
    @StateObject var spendsRepository: SpendsRepository // StateObject allows to 
    
    
    @State var statByCategories: [StatByCategories] = []
    @State var totalStat: Double = .zero
    
    @State var screenState: ScreenState = .loading
    enum ScreenState {
        case loading
        case data([Spends])
        case error(String)
    }
    
    func fetchData(showLoading: Bool) async {
        do {
            if showLoading {
                screenState = .loading
            }
            
            try await spendsRepository.fetch()
            
            screenState = .data(spendsRepository.sortedSpends)
        } catch {
            screenState = .error("Не смогли получить список трат")
        }
    }
    
    @State private var isEdit: Bool = false
    @State private var selectedSpend: Spends?
    
    @State private var loadDataOnce = true
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
                                    select(spend: spend)
                                }
                                .highlightOnSelect(isPressed: selectedSpend == spend)
                        }
                        .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
                    }
                case .error(let errorText):
                    Text(errorText)
                    Button("Reload") {
                        Task {
                            await fetchData(showLoading: true)
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
                withAnimation {
                    deselect()
                }
                if loadDataOnce {
                    loadDataOnce = false
                    
                    Task {
                        await fetchData(showLoading: true)
                    }
                }
            }
            .refreshable {
                Task {
                    await fetchData(showLoading: false)
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

struct HighlightOnSelect: ViewModifier {
    let isPressed: Bool
    func body(content: Content) -> some View {
        content
            .background(isPressed ? Color.gray.opacity(0.25) : Color.clear)
    }
}

extension View {
    func highlightOnSelect(isPressed: Bool) -> some View {
        modifier(HighlightOnSelect(isPressed: isPressed))
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
