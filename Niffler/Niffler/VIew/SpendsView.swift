import Api
import SwiftUI

struct SpendsView: View {
    @State var spends: [Spends] = []
    @State var isLoading = false
    @State var isPresentAddSpendView = false
    @EnvironmentObject var network: Api

    func fetchData() {
        Task {
            let (spends, response) = try await network.getSpends()

            await MainActor.run {
                self.spends = spends.map { Spends(dto: $0) }
                isLoading.toggle()
            }
        }
    }
}

extension SpendsView {
    var body: some View {
        VStack {
            HStack {
                AddSpendButton()
                RetrySpendsButton()
            }

            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                SpendsList()
            }
        }
        
        .onAppear {
            isLoading.toggle()
            fetchData()
        }
    }
}

extension SpendsView {
    @ViewBuilder
    func SpendsList() -> some View {
        List(spends) { spend in

            VStack(alignment: .leading) {
                Text("\(spend.spendDate)")
                    .font(.headline)

                Text("\(spend.amount)")
                    .font(.subheadline)
                Text("\(spend.currency)")
                Text("\(spend.category)")
                Text("\(spend.description)")
            }
        }
        .accessibilityIdentifier(SpendsViewIDs.spendsList.rawValue)
    }
    
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
    SpendsView()
}
