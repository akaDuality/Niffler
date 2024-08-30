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
    @State private var currency: String = "₽"
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
            VStack {
                HStack {
                    Text("\(editSpendView == nil ? "Add new spending" : "Edit spending")")
                        .font(.custom("YoungSerif-Regular", size: 24))
                        .padding()

                    Spacer()
                }
                SpendForm()
                SendSpendFormButton()
            }
        }
    }

    @ViewBuilder
    func SpendForm() -> some View {
        VStack(spacing: 16) {
            HStack {
                CustomTextField(
                    title: "Amount",
                    placeholder: "0",
                    text: $amount
                )
                .keyboardType(.numberPad)
                .focused($keyboardFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        keyboardFocused = true
                    }
                }

                CustomTextField(
                    title: "Currency",
                    placeholder: "₽",
                    text: $currency)
            }

            VStack {
                Text("Category")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker(
                    "Select category",
                    selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .padding()
                    .cornerRadius(8)
                    .background(AppColors.gray_50)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.gray_300, lineWidth: 1)
                    }
            }
            .padding()

            CustomTextField(
                title: "Description",
                placeholder: "Description",
                text: $description)

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
        .navigationTitle("\(editSpendView == nil ? "Add" : "Edit") Spend")
        .toolbar(content: {
            SendSpendFormButton()
        })
        .onAppear(perform: {
            if let editSpendView {
                amount = String(editSpendView.amount)
                spendDate = editSpendView.spendDate!
                description = editSpendView.description
                selectedCategory = editSpendView.category.name
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
                    category: CategoryDTO(name: selectedCategory, archived: false),
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
                Text("\(editSpendView == nil ? "Add" : "Edit") Spend")
            }
            .padding()
        }
    }

    @ViewBuilder
    func CustomTextField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField(placeholder, text: text)
                .padding()
                .cornerRadius(8)
                .background(AppColors.gray_50)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.gray_300, lineWidth: 1)
                }
        }
        .padding(.horizontal)
    }
}

#Preview {
    DetailSpendView(spends: .constant(
        preveiwSpends
    ),
    onAddSpend: {})
}
