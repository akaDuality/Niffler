import Api
import SwiftUI

struct DetailSpendView: View {
    @EnvironmentObject var api: Api

    let spendsRepository: SpendsRepository
    let onAddSpend: () -> Void
    var editSpendView: Spends?

    @State private var amount: String = Defaults.amount
    @State private var currency: String = "₽"
    @State private var spendDate: Date = Date()
    @State private var description: String = Defaults.description
    
    @EnvironmentObject var categoriesRepository: CategoriesRepository
    @State private var selectedCategory: String = Defaults.selectedCategory // Can vary during editing

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
        VStack(spacing: 0) {
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

            CategorySelectorView(selectedCategory: $selectedCategory)
                .padding()

            CustomTextField(
                title: "Description",
                placeholder: "Description",
                text: $description,
                accessibilityIdentifier: "descriptionField")
            .padding(2) // Show bottom line

            VStack(alignment: .leading, spacing: 10) {
                DatePicker("", selection: $spendDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
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
            } else {
                selectedCategory = categoriesRepository.selectedCategory
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
            category: categoriesRepository.currentCategoryDto,
            currency: "RUB",
            amount: Double(amount)!, // TODO: брать из amount string to double?
            description: description,
            username: "stage" // TODO: брать актуальный user name
        )
    }

    @ViewBuilder
    func SendSpendFormButton() -> some View {
        Button(action: {
            let newSpend = spendFromUI()
            if let editSpendView {
                // TODO: Improve?
            } else {
                addSpend(newSpend)
            }
        }) {
            Text("\(editSpendView == nil ? "Add" : "Edit") Spend")
                .frame(maxWidth: .infinity)
                .padding(16)
        }
        .font(.headline)
        .buttonStyle(.borderedProminent)
        .padding(16)
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
                .padding(8)
                .background(Color.gray50)
                .cornerRadius(8)
                .background(content: {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.gray_300, lineWidth: 1)
                })
                .accessibilityIdentifier(accessibilityIdentifier)
        }
        .padding(.horizontal)
    }
}

struct CategorySelectorView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Category")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                if categoriesRepository.categories.count > 0 {
                    Picker(
                        "Select category",
                        selection: $selectedCategory) {
                            ForEach(categoriesRepository.categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .padding(4)
                        .cornerRadius(8)
                        .background(Color.gray50)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.gray_300, lineWidth: 1)
                        }
                        .accessibilityIdentifier("Select category")
                }
                
                Button("+ Add") {
                    isAddCategoryAlertVisible = true
                }
                .alert("Add category", isPresented: $isAddCategoryAlertVisible) {
                    TextField("Name", text: $newCategoryName)
                    
                    Button(action: addCategory, label: {
                        Text("Add")
                    }).disabled(newCategoryName.isEmpty)
                    
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Input name for new category")
                }
            }
        }
    }
    
    @State private var isAddCategoryAlertVisible = false
    @State private var newCategoryName = ""
    
    init(selectedCategory: Binding<String>) {
        self._selectedCategory = selectedCategory
    }
    
    @Binding private var selectedCategory: String
    @EnvironmentObject var categoriesRepository: CategoriesRepository
    
    private func addCategory() {
        // Add to model
        categoriesRepository.add(newCategoryName)
        
        // Hide UI
        newCategoryName = ""
        isAddCategoryAlertVisible = false
        // Category will be added to server along with spend
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
