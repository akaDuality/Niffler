import Foundation
import Api

class CategoriesRepository: ObservableObject {
    
    init() {
        // TODO: Read from remote
        categories = [
            "Рыбалка", "Бары", "Рестораны",
            "Кино", "Автозаправки",
            "Спорт", "Кальян", "Продукты"]
    }
    
    @Published private(set) var categories: [String]
    
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
