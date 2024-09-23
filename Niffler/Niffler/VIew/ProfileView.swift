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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                UserInfo()
                Categories()
            }
            .navigationTitle("Profile")
            .padding()
        }
    }

    @ViewBuilder
    func UserInfo() -> some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))

            TextField("Surname", text: $surname)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))

            Picker("Currency", selection: $selectedCurrencyIndex) {
                ForEach(0 ..< currencies.count, id: \.self) { index in
                    Text(self.currencies[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button("Submit") {
                // TODO: Wotk with API, and Close profile? 
                saveChanges()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            setUserInfo()
        }
    }

    func setUserInfo() {
        name = userData.firstname ?? ""
        surname = userData.surname ?? ""
    }
    
    @ViewBuilder
    func Categories() -> some View {
        VStack {
            TextField("Add New Category", text: $newCategory)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 2))

            Button("Add Category") {
                addCategory()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .shadow(radius: 2))
            .foregroundColor(.white)
            .buttonStyle(.plain)

            // TODO: Support on delete https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-delete-rows-from-a-list
            ForEach(categoriesRepository.categories, id: \.self) { category in
                HStack {
                    Text(category)
                        .frame(maxWidth: .infinity)
                        .padding(5)
                }
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
            }
        }
        .padding()
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
