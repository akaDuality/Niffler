import SwiftUI

struct ProfileView: View {
    @State private var name: String = "Name"
    @State private var surname: String = "Surname"
    @State private var selectedCurrencyIndex = 0
    let currencies = ["USD", "EUR", "RUB", "KZT"]

    @State private var newCategory = ""
    
    @EnvironmentObject var categoriesRepository: CategoriesRepository
    @EnvironmentObject var userData: UserData
}

extension ProfileView {
    var body: some View {
        
        Form {
            UserInfo()
            CategoriesSection()
        }.navigationTitle("Profile")
    }

    @ViewBuilder
    func UserInfo() -> some View {
        Section(header: Text("User info")) {
            TextField("Name", text: $name)
                .multilineTextAlignment(.leading)


            TextField("Surname", text: $surname)
                .multilineTextAlignment(.leading)

            Picker("Currency", selection: $selectedCurrencyIndex) {
                ForEach(0 ..< currencies.count, id: \.self) { index in
                    Text(self.currencies[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Button(action: {
                // TODO: Work with API, and Close profile?
                saveChanges()
            }, label: {
                Text("Submit")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            
        }
        .onAppear {
            setUserInfo()
        }
    }

    func setUserInfo() {
        name = userData.firstname ?? ""
        surname = userData.surname ?? ""
    }
    
    @ViewBuilder
    func CategoriesSection() -> some View {
        Section(header: Text("Categories")) {
            ForEach(categoriesRepository.categories, id: \.self) { category in
                Text(category)
            }.onDelete { index in
                self.categoriesRepository.remove(index)
            }
            
            Button("Add Category") {
                // TODO: Show alert
            }
        }
        .listStyle(.insetGrouped)
    }

    func saveChanges() {
        print("Name: \(name)")
        print("Surname: \(surname)")
        print("Selected Currency: \(currencies[selectedCurrencyIndex])")

        // TODO: Work with API
    }

    func addCategory() {
        if !newCategory.isEmpty {
            categoriesRepository.add(newCategory)
            newCategory = ""
        }
    }
}

#Preview {
    ProfileView()
}
