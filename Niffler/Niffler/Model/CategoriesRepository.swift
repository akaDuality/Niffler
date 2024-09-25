import Foundation
import Api

class CategoriesRepository: ObservableObject {
    
    init(api: Api) {
        Task {
            // TODO: Handle failure
            let (categories, _) = try await api.categories()
            self.categoriesDto = categories
            self.categories = categories
                .filter(\.isActive)
                .map(\.name)
            
            self.selectedCategory = self.categories.first!// TODO: Remember last selected
        }
    }
    
    @Published private(set) var categories: [String] = []
    private var categoriesDto: [CategoryDTO] = []
    
    func add(_ newCategory: String) {
        categories.append(newCategory)
        selectedCategory = newCategory
        
        // TODO: Work with API
    }
    
    var selectedCategory: String = Defaults.selectedCategory
    
    var currentCategoryDto: CategoryDTO {
        categoriesDto.first { dto in
            dto.name == selectedCategory
        }!
    }
    
    func remove(_ indexSet: IndexSet) {
        categories.remove(atOffsets: indexSet)
    }
}
