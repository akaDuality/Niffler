import Foundation
import Api

class CategoriesRepository: ObservableObject {
    
    init(api: Api) {
        Task {
            // TODO: Handle failure
            let (categories, _) = try await api.categories()
            self.categories = categories
                .filter(\.isActive)
                .map(\.name)
        }
    }
    
    @Published private(set) var categories: [String] = []
    
    func add(_ newCategory: String) {
        categories.append(newCategory)
        selectedCategory = newCategory
        
        // TODO: Work with API
    }
    
    var selectedCategory: String = Defaults.selectedCategory
    
    var currentCategoryDto: CategoryDTO {
        CategoryDTO(name: selectedCategory, archived: false)
    }
}
