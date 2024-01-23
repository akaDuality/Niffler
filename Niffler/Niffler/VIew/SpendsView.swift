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
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        ForEach(spends) { spend in
                            SpendCard(spend: spend)
                        }
                    }
                    .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.gray.opacity(0.15))
                }
            }
            .onAppear {
                isLoading.toggle()
                fetchData()
            }
            .refreshable {
                isLoading.toggle()
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
