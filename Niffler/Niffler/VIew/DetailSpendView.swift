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
                // TODO: Show progress indicator
                let (spend, _) = try await api.addSpend(spend)
                
                await MainActor.run {
                    spendsRepository.add(spend)
                    onAddSpend()
                }
            } catch {
                let (spends, _) = try await api.getSpends()
                // TODO: Show alert
                print(error)
            }
        }
    }
    
    func edit(_ spend: Spends) {
        Task {
            do {
                let (spend, _) = try await api.editSpend(spend)
                
                await MainActor.run {
                    spendsRepository.replace(spend)
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
            SpendForm()
        }
    }

    @ViewBuilder
    func SpendForm() -> some View {
        VStack(spacing: 0) {
            HStack {
                
                TextField("amount", text: $amount)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("amountField")
                .keyboardType(.numberPad)
                .frame(maxWidth: .infinity)
                .focused($keyboardFocused)
                .padding(.vertical, 50)
                .onAppear {
                    keyboardFocused = true
                }
            }

            CustomTextField(
                title: "Description",
                placeholder: "Description",
                text: $description,
                accessibilityIdentifier: "descriptionField")
            .padding(2) // Show bottom line

            VStack(alignment: .leading, spacing: 10) {
                // TODO: Inline? https://stackoverflow.com/questions/75073023/how-to-trigger-swiftui-datepicker-programmatically
                DatePicker("", selection: $spendDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .background(.background, in: .rect(cornerRadius: 10))
                    .padding(.top, 50)
            }
        }
        .navigationTitle("\(editSpendView == nil ? "New" : "Edit") Spend")
        .onAppear(perform: {
            if let editSpendView {
                prefillForEditing(editSpendView)
            } else {
                // Read last used category
                selectedCategory = categoriesRepository.selectedCategory! // TODO: Handle unknown
            }
        })
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                CategorySelectorView(selectedCategory: $selectedCategory)
                
                Spacer()
                
                SendSpendFormButton()
            }
        }
    }
    
    private func prefillForEditing(_ spend: Spends) {
        amount = String(spend.amount)
        spendDate = spend.spendDate!
        description = spend.description
        selectedCategory = spend.category.name
    }
    
    private func spendFromUI() -> Spends {
        Spends(
            id: editSpendView?.id, // can be nil for new spend
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
            if editSpendView == nil {
                addSpend(newSpend)
            } else {
                edit(newSpend)
            }
        }) {
            Text(editSpendView == nil ? "Add" : "Edit")
                .padding(.horizontal, 16)
        }
        .font(.headline)
        .buttonStyle(.borderedProminent)
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
        Spacer()
        
        if categoriesRepository.categories.count > 0 {
            Menu(selectedCategory) {
                ForEach(categoriesRepository.categories, id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                    }
                }
                
                Divider()
                
                Button("+ New category") {
                    isAddCategoryAlertVisible = true
                }
            }
            .accessibilityIdentifier("Select category")
            .buttonStyle(.bordered)
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

        Spacer()
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
        id: nil,
        spendDate: DateFormatterHelper.shared
            .dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
        category: CategoryDTO(name: "Рыбалка", archived: false),
        currency: "RUB",
        amount: 69,
        description: "Test Spend",
        username: "stage"
    )
    let repository = SpendsRepository(api: Api())
    repository.add(testSpend)
    
    return DetailSpendView(spendsRepository: repository, onAddSpend: {})
        .environmentObject(CategoriesRepository(api: Api(), selectedCategory: ""))
}
