import Api
import SwiftUI

struct DetailSpendView: View {
    @EnvironmentObject var api: Api

    let spendsRepository: SpendsRepository
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

    init(spendsRepository: SpendsRepository,
         onAddSpend: @escaping () -> Void,
         editSpendView: Spends? = nil
    ) {
        self.spendsRepository = spendsRepository
        self.onAddSpend = onAddSpend
        self.editSpendView = editSpendView
    }

    func addSpend(_ spend: Spends) {
        Task {
            do {
                let (spendDto, _) = try await api.addSpend(spend)
                let spend = Spends(dto: spendDto)
                
                await MainActor.run {
                    spendsRepository.add(spend)
                    onAddSpend()
                }
            } catch {
                print(error)
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
                    text: $amount,
                    accessibilityIdentifier: "amountField"
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
                    text: $currency,
                    accessibilityIdentifier: "currencyField")
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
                    .accessibilityIdentifier("Select category")
            }
            .padding()

            CustomTextField(
                title: "Description",
                placeholder: "Description",
                text: $description,
                accessibilityIdentifier: "descriptionField")

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
                prefillForEditing(editSpendView)
            }
        })
    }
    
    private func prefillForEditing(_ spend: Spends) {
        amount = String(spend.amount)
        spendDate = spend.spendDate!
        description = spend.description
        selectedCategory = spend.category.name
    }
    
    private func spendFromUI() -> Spends {
        Spends(
            spendDate: spendDate,
            category: CategoryDTO(name: selectedCategory, archived: false),
            currency: "RUB",
            amount: Double(amount)!, // брать из amount amount string to double?
            description: description,
            username: "stage" // прикапывать user name
        )
    }

    @ViewBuilder
    func SendSpendFormButton() -> some View {
        VStack {
            Button(action: {
                let newSpend = spendFromUI()
                if let editSpendView {
                    // TODO: Improve?
                } else {
                    addSpend(newSpend)
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
        text: Binding<String>,
        accessibilityIdentifier: String
    ) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField(placeholder, text: text)
                .padding()
                .cornerRadius(8)
                .background(AppColors.gray_50)
                .background(content: {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.gray_300, lineWidth: 1)
                })
                .accessibilityIdentifier(accessibilityIdentifier)
        }
        .padding(.horizontal)
    }
}

#Preview {
    let testSpend = Spends(
        spendDate: DateFormatterHelper.shared
            .dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "Рыбалка", archived: false),
        currency: "RUB",
        amount: 69,
        description: "Test Spend",
        username: "stage"
    )
    let repository = SpendsRepository()
    repository.add(testSpend)
    
    return DetailSpendView(spendsRepository: repository, onAddSpend: {})
}
