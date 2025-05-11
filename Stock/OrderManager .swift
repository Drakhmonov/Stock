//
//  OrderManager .swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import Foundation

class OrderManager {
    static let shared = OrderManager()
    private init() {}

    /// All orders that the kitchen and delivery workflows will act upon.
    var ordersForKitchen: [PlacedOrder] = []

    // MARK: - Adding Orders

    /// Add a new branch order with optional branch note.
    func addOrder(branchName: String, items: [CustomStockItem], note: String? = nil) {
        var newOrder = PlacedOrder(branchName: branchName,
                                   items: items,
                                   isPrepared: false)
        newOrder.kitchenNote = note
        ordersForKitchen.append(newOrder)
    }

    // MARK: - Kitchen Workflow

    /// Move an order from Pending → Preparing.
    func markOrderAsPreparing(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isPreparing = true
        ordersForKitchen[index].preparingAt = Date()
    }

    /// Move an order from Preparing → Prepared.
    func markOrderAsPrepared(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isPrepared = true
        ordersForKitchen[index].preparedAt = Date()
    }

    /// Undo a Prepared state (Prepared → Preparing or Pending).
    func unmarkPrepared(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isPrepared = false
        ordersForKitchen[index].preparedAt = nil
        // Optionally reset isPreparing:
        // ordersForKitchen[index].isPreparing = false
        // ordersForKitchen[index].preparingAt = nil
    }

    // MARK: - Delivery Workflow

    /// Move an order from Prepared → Collected.
    func markOrderAsCollected(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isCollected = true
        ordersForKitchen[index].collectedAt = Date()
    }

    /// Move an order from Collected → Delivered.
    func markOrderAsDelivered(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isDelivered = true
        ordersForKitchen[index].deliveredAt = Date()
    }

    /// Undo a Delivered state (Delivered → Collected).
    func unmarkDelivered(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isDelivered = false
        ordersForKitchen[index].deliveredAt = nil
    }
}

