//
//  OrderManager .swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import Foundation

class OrderManager {
    /// Shared singleton instance
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

    /// Undo a Prepared state (Prepared → Pending).
    func unmarkPrepared(at index: Int) {
        guard ordersForKitchen.indices.contains(index) else { return }
        ordersForKitchen[index].isPrepared = false
        ordersForKitchen[index].preparedAt = nil
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

// MARK: - Reporting & Aggregation
extension OrderManager {
    /// Returns all orders whose placedAt falls within the interval.
    func orders(placedIn interval: DateInterval) -> [PlacedOrder] {
        return ordersForKitchen.filter { interval.contains($0.placedAt) }
    }

    /// Total number of orders placed in interval.
    func totalOrders(in interval: DateInterval) -> Int {
        return orders(placedIn: interval).count
    }

    /// Total orders prepared in interval.
    func preparedOrders(in interval: DateInterval) -> Int {
        return orders(placedIn: interval)
            .filter { $0.isPrepared && ($0.preparedAt.map(interval.contains) ?? false) }
            .count
    }

    /// Total orders collected in interval.
    func collectedOrders(in interval: DateInterval) -> Int {
        return orders(placedIn: interval)
            .filter { $0.isCollected && ($0.collectedAt.map(interval.contains) ?? false) }
            .count
    }

    /// Total orders delivered in interval.
    func deliveredOrders(in interval: DateInterval) -> Int {
        return orders(placedIn: interval)
            .filter { $0.isDelivered && ($0.deliveredAt.map(interval.contains) ?? false) }
            .count
    }

    /// Average time (in seconds) between placedAt → preparedAt for orders prepared in interval.
    func averagePrepTime(in interval: DateInterval) -> TimeInterval {
        let durations = orders(placedIn: interval)
            .compactMap { order -> TimeInterval? in
                guard let prepDate = order.preparedAt,
                      interval.contains(prepDate)
                else { return nil }
                return prepDate.timeIntervalSince(order.placedAt)
            }
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }

    /// Average time (in seconds) between preparedAt → deliveredAt for orders delivered in interval.
    func averageDeliveryTime(in interval: DateInterval) -> TimeInterval {
        let durations = orders(placedIn: interval)
            .compactMap { order -> TimeInterval? in
                guard let prepDate = order.preparedAt,
                      let delDate  = order.deliveredAt,
                      interval.contains(delDate)
                else { return nil }
                return delDate.timeIntervalSince(prepDate)
            }
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }
    
    func itemUsagePerBranch(in interval: DateInterval) -> [String: [String: Int]] {
        // Filter orders placed in interval
        let orders = ordersForKitchen.filter { interval.contains($0.placedAt) }

        // Reduce into a nested dictionary
        var usage: [String: [String: Int]] = [:]

        for order in orders {
          let branch = order.branchName
          let items = order.items  // or order.preparedItems where appropriate

          // Initialize branch dictionary if needed
          if usage[branch] == nil {
            usage[branch] = [:]
          }

          for item in items {
            usage[branch]![item.name, default: 0] += item.quantity
          }
        }

        return usage
      }
    
    func deliveredItemUsagePerBranch(in interval: DateInterval)
           -> [String: [String: Int]] {
        // 1) Pick orders delivered in the interval
        let delOrders = ordersForKitchen.filter {
          $0.isDelivered
            && $0.deliveredAt.map(interval.contains) == true
        }

        // 2) Build the nested dictionary
        var usage: [String: [String:Int]] = [:]
        for order in delOrders {
          let branch = order.branchName
          let items  = order.preparedItems ?? order.items

          if usage[branch] == nil { usage[branch] = [:] }
          for item in items {
            usage[branch]![item.name, default: 0] += item.quantity
          }
        }
        return usage
      }
    
}
