import Api
import SwiftUI

struct SpendsView: View {
    @State var spends: [Spends] = []

    let network = Api()
    
    func fetchData() {
        Task {
            try await network.auth.authorize(user: "stage", password: "12345")
            
            let (spends, response) = try await network.getSpends()
            
            await MainActor.run {
                self.spends = spends
            }
        }
    }
}

extension SpendsView {
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
            fetchData()
        }
    }
}


#Preview {
    SpendsView()
}
