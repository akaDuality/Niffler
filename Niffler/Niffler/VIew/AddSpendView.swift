import Api
import SwiftUI

struct AddSpendView: View {
    let network: Api
    @Binding var spends: [Spends]
    let onAddSpend: () -> Void

    let categories: [String] = ["Рыбалка", "Бары", "Рестораны",
                                "Кино", "Автозаправки",
                                "Спорт", "Кальян", "Продукты"]

    @State private var amount: String = "20.00"
    @State private var spendDate: Date = Date()
    @State private var description: String = "Hello kitty"
    @State private var selectedCategory: String = ""
    
    
    // DateFormatterHelper из API недоступен для использования
    private func dateFormater(_ dateForm: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: dateForm)
    }

    init(network: Api,
         spends: Binding<[Spends]>,
         onAddSpend: @escaping () -> Void,
         selectedCategory: String = "") {
        self.network = network
        _spends = spends
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

            DatePicker("Select a date", selection: $spendDate, displayedComponents: [.date])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            Section {
                TextField("Description", text: $description)
            }
        }
    }

    @ViewBuilder
    func SendSpendFormButton() -> some View {
        VStack {
            Button(action: {
                
                let amountDouble = Double(amount)!
                
                let spend = Spends(
                    spendDate: dateFormater(spendDate),
                    category: selectedCategory,
                    currency: "RUB",
                    amount: amountDouble, // брать из amount amount string to double?
                    description: description,
                    username: "stage" // прикапывать user name
                )
                addSpend(spend)
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

class DateFormatterApi {
    
}
