//
//  ContentView.swift
//  Niffler
//
//  Created by Mikhail Rubanov on 21.11.2023.
//

import SwiftUI
import SwiftData
import Api

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        ZStack {
            LoginView()
        }
    }
        
        private func addItem() {
            withAnimation {
                let newItem = Item(timestamp: Date())
                modelContext.insert(newItem)
            }
        }
        
        private func deleteItems(offsets: IndexSet) {
            withAnimation {
                for index in offsets {
                    modelContext.delete(items[index])
                }
            }
        }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
