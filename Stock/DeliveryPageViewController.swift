//
//  DeliveryPageViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//

import UIKit

class DeliveryPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: – UI Components
    
    private let summaryStack   = UIStackView()
    private let pendingLabel   = UILabel()
    private let collectedLabel = UILabel()
    private let deliveredLabel = UILabel()
    private let tableView      = UITableView()
    
    // MARK: – Data
    
    private var pendingDelivery:  [PlacedOrder] = []
    private var collectedOrders:  [PlacedOrder] = []
    private var deliveredOrders:  [PlacedOrder] = []
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()
    
    // MARK: – Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Delivery"
        view.backgroundColor = .white
        
        // 1) Summary bar
        summaryStack.axis         = .horizontal
        summaryStack.distribution = .equalSpacing
        summaryStack.alignment    = .center
        summaryStack.spacing      = 16
        [pendingLabel, collectedLabel, deliveredLabel].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            summaryStack.addArrangedSubview($0)
        }
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryStack)
        
        // 2) Table view
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeliveryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 3) Layout
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            summaryStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryStack.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: summaryStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadOrders()
    }
    
    // MARK: – Data Loading
    
    private func reloadOrders() {
        let all = OrderManager.shared.ordersForKitchen
        pendingDelivery = all.filter { $0.isPrepared  && !$0.isCollected }
        collectedOrders = all.filter { $0.isCollected && !$0.isDelivered }
        deliveredOrders = all.filter { $0.isDelivered }
        
        // Update summary labels
        pendingLabel.text   = "🚚 Pending: \(pendingDelivery.count)"
        collectedLabel.text = "📦 Collected: \(collectedOrders.count)"
        deliveredLabel.text = "✅ Delivered: \(deliveredOrders.count)"
        
        tableView.reloadData()
    }
    
    // MARK: – UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return pendingDelivery.count
            case 1: return collectedOrders.count
            default: return deliveredOrders.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "🚚 Pending Delivery"
            case 1: return "📦 Order Collected"
            default: return "✅ Delivered"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DeliveryCell")
        cell.selectionStyle = .none
        
        let order: PlacedOrder = {
            if indexPath.section == 0 { return pendingDelivery[indexPath.row] }
            if indexPath.section == 1 { return collectedOrders[indexPath.row] }
            return deliveredOrders[indexPath.row]
        }()
        
        cell.textLabel?.text = order.branchName
        cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        
        var lines: [String] = []
        if let items = order.preparedItems {
            lines.append(contentsOf: items.map { "• \($0.name): \($0.quantity)" })
        }
        if let note = order.kitchenNote, !note.isEmpty {
            lines.append("📩 Note: \(note)")
        }
        if let preparedAt = order.preparedAt {
            lines.append("✅ Prepared: \(dateFormatter.string(from: preparedAt))")
        }
        if indexPath.section >= 1, let collectedAt = order.collectedAt {
            lines.append("⏱ Collected: \(dateFormatter.string(from: collectedAt))")
        }
        if indexPath.section == 2, let deliveredAt = order.deliveredAt {
            lines.append("🏁 Delivered: \(dateFormatter.string(from: deliveredAt))")
        }
        
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = lines.joined(separator: "\n")
        
        return cell
    }
    
    // MARK: – UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let order = (indexPath.section == 0 ? pendingDelivery :
                     indexPath.section == 1 ? collectedOrders :
                     deliveredOrders)[indexPath.row]
        guard let idx = OrderManager.shared.ordersForKitchen.firstIndex(where: {
            $0.branchName == order.branchName && $0.placedAt == order.placedAt
        }) else { return }
        
        switch indexPath.section {
        case 0:
            let alert = UIAlertController(title: "Mark as Collected?",
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "✅ Collected", style: .default) { _ in
                OrderManager.shared.markOrderAsCollected(at: idx)
                self.reloadOrders()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        case 1:
            let alert = UIAlertController(title: "Mark as Delivered?",
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "✅ Delivered", style: .default) { _ in
                OrderManager.shared.markOrderAsDelivered(at: idx)
                self.reloadOrders()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        case 2:
            let alert = UIAlertController(title: "Undo Delivered?",
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                OrderManager.shared.unmarkDelivered(at: idx)
                self.reloadOrders()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        default:
            break
        }
    }
}

