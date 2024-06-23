import Api
import SwiftUI

struct SpendsView: View {
    @Binding var spends: [Spends]
    @State var isLoading = false
    @EnvironmentObject var api: Api

    func fetchData() {
        Task {
            let (spends, _) = try await api.getSpends()

            await MainActor.run {
                self.spends = spends.content.map { Spends(dto: $0) }
                isLoading = false
            }
        }
    }
}

extension SpendsView {
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    VStack {
                        StatisticView(spends: $spends)

                        LazyVStack {
                            ForEach(sortedByDateDesc(spends)) { spend in
                                NavigationLink(value: spend) {
                                    SpendCard(spend: spend)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
                    }
                }
            }
            .navigationDestination(for: Spends.self) { spend in
                DetailSpendView(spends: $spends, onAddSpend: {}, editSpendView: spend)
            }
            .onAppear {
                // TODO: обернуть в ифчик чтобы не крутилось
                isLoading = true
                fetchData()
            }
            .refreshable {
                fetchData()
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
        category: "Рыбалка",
        currency: "RUB",
        amount: 180,
        description: "Test Spend",
        username: "stage"
    ),
    Spends(
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: "Кальян",
        currency: "RUB",
        amount: 120,
        description: "Test Spend",
        username: "stage"
    ),
    Spends(
        spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: "Не рыбалка",
        currency: "RUB",
        amount: 500,
        description: "Test Spend",
        username: "stage"
    ),
]
