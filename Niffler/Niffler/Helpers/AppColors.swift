import Foundation
import SwiftUI

struct AppColors {
    static let blue_100 = Color(hex: "#2941CC")
    static let green = Color(hex: "35AD7B")
    static let gray_50 = Color(hex: "#FAFAFD")
    static let gray_700 = Color(hex: "#84889A")
    static let gray_1000 = Color(hex: "#242527")
}

extension Color {
    // Function to create Color from hexadecimal string
    init(hex: String) {
        var formattedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if formattedHex.hasPrefix("#") {
            formattedHex.remove(at: formattedHex.startIndex)
        }
        
        // Convert hex to UInt32
        guard let rgbValue = UInt32(formattedHex, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        // Extract RGB components
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        // Create Color
        self.init(red: red, green: green, blue: blue)
    }
}
