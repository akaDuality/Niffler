import Foundation
import Api

class CategoriesRepository: ObservableObject {
    
    let api: Api
    
    init(api: Api) {
        self.api = api
        Task {
            try await loadCategories()
        }
    }
    
    private func loadCategories() async throws {
        // TODO: Handle failure
        let (categories, _) = try await api.categories()
        self.categoriesDto = categories
        self.categories = categories
            .filter(\.isActive)
            .map(\.name)
        
        self.selectedCategory = self.categories.first!// TODO: Remember last selected
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
        var removedCategory = categoriesDto[indexSet.first!]
        categories.remove(atOffsets: indexSet)
        removedCategory.archived = true
        
        Task {
            do {
                _ = try await api.updateCategory(removedCategory)
            } catch {
                // TODO: Show in UI
                print(error)
            }
        }
    }
}

extension Sequence {
    subscript(index: Int) -> Self.Iterator.Element? {
        return enumerated().first(where: {$0.offset == index})?.element
    }
}
