import Api
import SwiftUI

struct SpendsView: View {
    @State var spends: [Spends] = []
    @State var isLoading = false
    let network: Api

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
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }

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
            Text("Spends View?")
        }
        .onAppear {
            isLoading.toggle()
            fetchData()
        }
        .accessibilityIdentifier(SpendsViewIDs.spendsView.rawValue)
        
    }
}

// #Preview {
//    SpendsView()
// }
