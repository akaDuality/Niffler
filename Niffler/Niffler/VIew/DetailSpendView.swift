import Api
import SwiftUI

struct DetailSpendView: View {
    @EnvironmentObject var api: Api

    @Binding var spends: [Spends]
    let onAddSpend: () -> Void
    var editSpendView: Spends?

    let categories: [String] = ["Рыбалка", "Бары", "Рестораны",
                                "Кино", "Автозаправки",
                                "Спорт", "Кальян", "Продукты"]

    @State private var amount: String = Defaults.amount
    @State private var spendDate: Date = Date()
    @State private var description: String = Defaults.description
    @State private var selectedCategory: String = Defaults.selectedCategory
    @FocusState private var keyboardFocused: Bool

    init(spends: Binding<[Spends]>,
         onAddSpend: @escaping () -> Void,
         editSpendView: Spends? = nil
    ) {
        _spends = spends
        self.onAddSpend = onAddSpend
        self.editSpendView = editSpendView
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

extension DetailSpendView {
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
        .navigationTitle("\(editSpendView == nil ? "Add": "Edit") Spend")
        .toolbar(content: {
            SendSpendFormButton()
        })
        .onAppear(perform: {
            if let editSpendView {
                amount = String(editSpendView.amount)
                spendDate = editSpendView.spendDate!
                description = editSpendView.description
                selectedCategory = editSpendView.category
            }
        })
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
                if let editSpendView {
                    
                } else {
                    addSpend(spend)
                }
            }) {
                Text("\(editSpendView == nil ? "Add": "Edit") Spend")
            }
            .padding()
        }
    }
}

#Preview {
    DetailSpendView(spends: .constant([Spends(
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
