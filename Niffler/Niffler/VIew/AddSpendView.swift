import Api
import SwiftUI

struct AddSpendView: View {
    let categories: [String] = ["Рыбалка", "Бары", "Рестораны",
                                "Кино", "Автозаправки",
                                "Спорт", "Кальян", "Продукты"]

    @State private var selectedCategory: String = ""
    @State private var amount: String = ""
    @State private var spendDate: String = ""
    @State private var description: String = ""
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
