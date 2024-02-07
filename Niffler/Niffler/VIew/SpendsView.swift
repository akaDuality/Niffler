import Api
import SwiftUI

struct SpendsView: View {
    @State var spends: [Spends] = []
    @State var isLoading = false
    @State var isPresentAddSpendView = false
    @EnvironmentObject var api: Api

    func fetchData() {
        Task {
            let (spends, _) = try await api.getSpends()

            await MainActor.run {
                self.spends = spends.map { Spends(dto: $0) }
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
                        ForEach(spends) { spend in
                            NavigationLink(value: spend) {
                                SpendCard(spend: spend)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.gray.opacity(0.15))
                }
            }
            .navigationDestination(for: Spends.self) { spend in
                DetailSpendView(spends: $spends, onAddSpend: {},editSpendView: spend)
            }
            .onAppear {
                isLoading = true
                fetchData()
            }
            .refreshable {
                fetchData()
            }

            VStack {
                AddSpendButton()
            }
        }
    }
}

extension SpendsView {
    @ViewBuilder
    func AddSpendButton() -> some View {
        HStack {
            Spacer()
            Button(action: {
                isPresentAddSpendView.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .sheet(isPresented: $isPresentAddSpendView) {
            DetailSpendView(
                spends: $spends,
                onAddSpend: {
                    self.isPresentAddSpendView = false
                }
            )
        }
        .accessibilityIdentifier(SpendsViewIDs.addSpendButton.rawValue)
    }

    @ViewBuilder
    func RetrySpendsButton() -> some View {
        HStack {
            Button(action: {
                fetchData()
                isLoading.toggle()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    ContentView()
}
