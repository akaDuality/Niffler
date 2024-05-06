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
