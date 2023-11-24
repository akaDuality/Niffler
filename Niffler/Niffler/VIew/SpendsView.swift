import Api
import SwiftUI

struct SpendsView: View {
    @ObservedObject var spendsModel = SpendsViewModel()
    @State var spends: [Spends] = []

    var body: some View {
        VStack {
            List(spends) { spend in
                VStack(alignment: .leading) {
                    Text("ID: \(spend.id)")
                }
            }
            Text("Spends View?")
        }
        .onAppear {
            Task {
                let spends = try await spendsModel.fetchData()
                
                await MainActor.run {
                    self.spends = spends
                }
            }
        }
    }
}

class SpendsViewModel: ObservableObject {
    let network = Api()

    func fetchData() async throws -> [Spends] {
        try await network.auth.authorize(user: "stage", password: "12345")

        let (spends, response) = try await network.getSpends()
        return spends
    }
}

#Preview {
    SpendsView()
}
