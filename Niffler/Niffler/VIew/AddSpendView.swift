import Api
import SwiftUI

struct AddSpendView: View {
    let network: Api
    @Binding var spends: [Spends]
    let onAddSpend: () -> Void

    let categories: [String] = ["Рыбалка", "Бары", "Рестораны",
                                "Кино", "Автозаправки",
                                "Спорт", "Кальян", "Продукты"]
    
    @State private var amount: String = ""
    @State private var spendDate: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: String = ""

    init(network: Api,
         spends: Binding<[Spends]>,
         onAddSpend: @escaping () -> Void,
         selectedCategory: String = "") {
        self.network = network
        self._spends = spends
        self.onAddSpend = onAddSpend
        self.selectedCategory = selectedCategory.isEmpty ? categories[0] : selectedCategory
    }
    
    func addSpend(_ spend: Spends) {
        Task {
            let (spendDto, response) = try await network.addSpend(spend)
            let spend = Spends(dto: spendDto)
            await MainActor.run {
                spends.append(spend)
                onAddSpend()
            }
        }
    }
}

extension AddSpendView {
    var body: some View {
        VStack {
            SpendForm()
            SendSpendFormButton()
        }
    }

    @ViewBuilder
    func SpendForm() -> some View {
        Form {
            Section {
                Picker(
                    "Select category",
                    selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
            }

            Section {
                TextField("Amount", text: $amount)
            }

            Section {
                TextField("Spend Date", text: $spendDate)
            }

            Section {
                TextField("Description", text: $description)
            }
        }
    }

    @ViewBuilder
    func SendSpendFormButton() -> some View {
        VStack {
            Button(action: {
                var spend = Spends(
                    spendDate: spendDate,
                    category: selectedCategory,
                    currency: "RUB",
                    amount: 69, // брать из amount amount string to double?
                    description: description,
                    username: "stage" // прикапывать user name
                )
                let testSpend = Spends(
                    spendDate: "2023-12-07T05:00:00.000+00:00",
                    category: "Рыбалка",
                    currency: "RUB",
                    amount: 69,
                    description: "Test Spend 3",
                    username: "stage"
                )
                addSpend(testSpend)
                print(selectedCategory)
                print(amount)
                print(spendDate)
            }) {
                Text("Add spend")
                    
            }
            .padding()
        }
    }
}

// #Preview {
//    AddSpendView()
// }
