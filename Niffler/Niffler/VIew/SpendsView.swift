import Api
import SwiftUI

struct SpendsView: View {
    @State var spends: [Spends] = []
    @State var isLoading = false
    @State var isPresentAddSpendView = false
    @EnvironmentObject var api: Api

    func fetchData() {
        Task {
            let (spends, response) = try await api.getSpends()

            await MainActor.run {
                self.spends = spends.map { Spends(dto: $0) }
                isLoading.toggle()
            }
        }
    }
}

extension SpendsView {
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                Section {
                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        VStack {
                            ForEach(spends) { spend in
                                SpendCard(spend: spend)
                            }
                            .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                } header: {
                    HStack {
                        AddSpendButton()
                        RetrySpendsButton()
                    }
                }
            }
        }
        .background(.gray.opacity(0.15))
        .onAppear {
            isLoading.toggle()
            fetchData()
        }
    }
}

extension SpendsView {
    @ViewBuilder
    func AddSpendButton() -> some View {
        HStack {
            Button(action: {
                isPresentAddSpendView.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $isPresentAddSpendView) {
            AddSpendView(
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
