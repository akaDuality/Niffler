import Foundation

public class CategoriesRepository: ObservableObject {
    
    let api: Api
    
    public init(api: Api, selectedCategory: String?) {
        self.api = api
        self.selectedCategory = selectedCategory
    }
    
    @MainActor
    public func loadCategories() async throws {
        // TODO: Handle failure
        let (categories, _) = try await api.categories()
        self.categoriesDto = categories
        self.categories = categories
            .filter(\.isActive)
            .map(\.name)
        
        self.selectedCategory = selectedCategory ?? self.categories.first!
    }
    
    public func add(_ newCategory: String) {
        categories.append(newCategory)
        selectedCategory = newCategory
        
        // TODO: Work with API
    }
    
    @Published public private(set) var categories: [String] = []
    
    public private(set) var selectedCategory: String?
    
    private var categoriesDto: [CategoryDTO] = []
    
    public var currentCategoryDto: CategoryDTO {
        categoriesDto.first { dto in
            dto.name == selectedCategory
        } ?? makeNewCategory()
    }
    
    private func makeNewCategory() -> CategoryDTO {
        CategoryDTO(id: nil, name: selectedCategory!, // TODO: Make it optional
                    username: nil, archived: false)
    }
    
    public func remove(_ indexSet: IndexSet) {
        var removedCategory = categoriesDto[indexSet.first!]
        categories.remove(atOffsets: indexSet)
        removedCategory.archived = true
        
        // TODO: Select another one if needed
        
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
