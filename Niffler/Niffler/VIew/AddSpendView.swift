import Api
import SwiftUI

struct AddSpendView: View {
    @EnvironmentObject var api: Api
    let dateFormatter = DateFormatterHelper()
    
    @Binding var spends: [Spends]
    let onAddSpend: () -> Void

    let categories: [String] = ["Рыбалка", "Бары", "Рестораны",
                                "Кино", "Автозаправки",
                                "Спорт", "Кальян", "Продукты"]

    @State private var amount: String = "20.00"
    @State private var spendDate: Date = Date()
    @State private var description: String = "Hello kitty"
    @State private var selectedCategory: String = "Рыбалка"

    init(spends: Binding<[Spends]>,
         onAddSpend: @escaping () -> Void) {
        _spends = spends
        self.onAddSpend = onAddSpend
    }

    func addSpend(_ spend: Spends) {
        Task {
            let (spendDto, response) = try await api.addSpend(spend)
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
            Section(header: Text("Category")) {
                Picker(
                    "Select category",
                    selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
            }
            
            Section(header: Text("Amount")) {
                TextField("Amount", text: $amount)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Spend Date")) {
                DatePicker("Select a date", selection: $spendDate, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
            }

            Section(header: Text("Description")) {
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
                    spendDate: dateFormatter.formatToApi(spendDate),
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
