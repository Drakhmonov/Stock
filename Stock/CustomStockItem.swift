//
//  StockItem.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import Foundation

// Define StockItem model
struct CustomStockItem {
    let name: String  // Use `let` for immutability
    var quantity: Int
    
    // Custom initializer if needed
    init(name: String, quantity: Int) {
        self.name = name
        self.quantity = quantity
    }
}

// Conform to Equatable to compare CustomStockItems (optional)
extension CustomStockItem: Equatable {
    static func == (lhs: CustomStockItem, rhs: CustomStockItem) -> Bool {
        return lhs.name == rhs.name && lhs.quantity == rhs.quantity
    }
}

