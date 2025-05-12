//
//  PlacedOrder.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//

import Foundation

struct PlacedOrder {
    var branchName: String
    var items: [CustomStockItem]

    // Kitchen flow
    var isPreparing: Bool = false         // ← New
    var preparingAt: Date?                // ← New
    var isPrepared: Bool
    var preparedAt: Date?
    

    // Delivery flow
    var isCollected: Bool = false
    var collectedAt: Date?
    var isDelivered: Bool = false
    var deliveredAt: Date?

    var kitchenNote: String?
    var preparedItems: [CustomStockItem]?
    var placedAt: Date = Date()
}


