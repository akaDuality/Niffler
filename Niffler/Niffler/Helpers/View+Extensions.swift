import SwiftUI

extension View {
    func currencyString(_ value: Double, allowDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = allowDigits

        return formatter.string(from: .init(value: value)) ?? ""
    }
}
