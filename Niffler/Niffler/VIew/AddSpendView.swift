import Api
import SwiftUI

struct AddSpendView: View {
    @EnvironmentObject var api: Api

    @Binding var spends: [Spends]
    let onAddSpend: () -> Void

    let categories: [String] = ["Рыбалка", "Бары", "Рестораны",
                                "Кино", "Автозаправки",
                                "Спорт", "Кальян", "Продукты"]

    @State private var amount: String = Defaults.amount
    @State private var spendDate: Date = Date()
    @State private var description: String = Defaults.description
    @State private var selectedCategory: String = Defaults.selectedCategory
    @FocusState private var keyboardFocused: Bool

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
        ScrollView(.vertical) {
            VStack(spacing: 15) {
                SpendForm()
                SendSpendFormButton()
            }
            .padding(15)
        }
        .background(.gray.opacity(0.15))
    }

    @ViewBuilder
    func SpendForm() -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Category")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Amount", text: $amount)
                    .keyboardType(.numberPad)
                    .focused($keyboardFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            keyboardFocused = true
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(.background, in: .rect(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Amount")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker(
                    "Select category",
                    selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(.background, in: .rect(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Description")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Description", text: $description)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(.background, in: .rect(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Spend Date")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                DatePicker("", selection: $spendDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(.background, in: .rect(cornerRadius: 10))
            }
        }
    }

    @ViewBuilder
    func SendSpendFormButton() -> some View {
        VStack {
            Button(action: {
                let amountDouble = Double(amount)!

                let spend = Spends(
                    spendDate: spendDate,
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

#Preview {
    AddSpendView(spends: .constant([Spends(
        spendDate: DateFormatterHelper.shared
            .dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: "Рыбалка",
        currency: "RUB",
        amount: 69,
        description: "Test Spend",
        username: "stage"
    )]),
    onAddSpend: {})
}
