import Api
import SwiftUI

struct SpendsView: View {
    @State var spends: [Spends] = []
    @State var isLoading = false
    @Binding var isRegistrationPresented: Bool
    let network: Api

    func fetchData() {
        Task {
//            try await network.auth.authorize(user: "stage", password: "12345")

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
            Button(action: {
                isRegistrationPresented.toggle()
            }) {
                Text("Выйти")
            }

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
    }
}

// #Preview {
//    SpendsView()
// }
