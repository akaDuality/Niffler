//
//  Item.swift
//  Niffler
//
//  Created by Mikhail Rubanov on 21.11.2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
