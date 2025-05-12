//
//  KitchenOrdersViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//


import UIKit

class KitchenOrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: – UI Components
    
    private let summaryStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .equalSpacing
        s.alignment = .center
        s.spacing = 16
        return s
    }()
    private let pendingLabel   = UILabel()
    private let preparingLabel = UILabel()
    private let preparedLabel  = UILabel()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: – Data
    
    private var pendingOrders:   [PlacedOrder] = []
    private var preparingOrders: [PlacedOrder] = []
    private var preparedOrders:  [PlacedOrder] = []
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()
    
    // MARK: – Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kitchen Orders"
        view.backgroundColor = .systemBackground
        
        // Summary bar
        [pendingLabel, preparingLabel, preparedLabel].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            summaryStack.addArrangedSubview($0)
        }
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryStack)
        
        // Table view
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(KitchenOrderCardCell.self,
                           forCellReuseIdentifier: KitchenOrderCardCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Layout
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
        pendingOrders   = all.filter { !$0.isPreparing && !$0.isPrepared }
        preparingOrders = all.filter { $0.isPreparing && !$0.isPrepared }
        preparedOrders  = all.filter { $0.isPrepared }
        
        // Update summary
        pendingLabel.text   = "🕒 Pending: \(pendingOrders.count)"
        preparingLabel.text = "🔧 Preparing: \(preparingOrders.count)"
        preparedLabel.text  = "✅ Prepared: \(preparedOrders.count)"
        
        tableView.reloadData()
    }
    
    // MARK: – UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return pendingOrders.count
        case 1: return preparingOrders.count
        default: return preparedOrders.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "🕒 Pending Orders"
        case 1: return "🔧 Preparing Orders"
        default: return "✅ Prepared Orders"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = pendingOrders[indexPath.row]
        case 1: order = preparingOrders[indexPath.row]
        default: order = preparedOrders[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: KitchenOrderCardCell.reuseIdentifier,
            for: indexPath
        ) as! KitchenOrderCardCell
        cell.configure(with: order, dateFormatter: dateFormatter)
        return cell
    }
    
    // MARK: – Helper
    
    /// Build a multiline summary of items + branch note
    private func summaryMessage(for order: PlacedOrder) -> String {
        // Item lines
        let itemsText = order.items
            .map { "• \($0.quantity)x \($0.name)" }
            .joined(separator: "\n")
        
        // Branch note if present
        let noteText: String
        if let note = order.kitchenNote, !note.trimmingCharacters(in: .whitespaces).isEmpty {
            noteText = "\n\n📩 Note: \(note)"
        } else {
            noteText = ""
        }
        
        return itemsText + noteText
    }
    
    // MARK: – UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Pick the correct order object
        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = pendingOrders[indexPath.row]
        case 1: order = preparingOrders[indexPath.row]
        default: order = preparedOrders[indexPath.row]
        }
        
        // Find its index in the shared array
        guard let idx = OrderManager.shared.ordersForKitchen.firstIndex(where: {
            $0.branchName == order.branchName && $0.placedAt == order.placedAt
        }) else { return }
        
        switch indexPath.section {
        case 0:
            // Pending → show full order summary and Start Preparing
            let message = summaryMessage(for: order)
            let alert = UIAlertController(
                title: "\(order.branchName) Order",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Start Preparing", style: .default) { _ in
                OrderManager.shared.markOrderAsPreparing(at: idx)
                self.reloadOrders()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        case 1:
            // Preparing → push into full Prepare screen
            let prepareVC = PrepareOrderViewController(orderIndex: idx, order: order)
            navigationController?.pushViewController(prepareVC, animated: true)
            
        case 2:
                // 1) Build the base summary + prepared timestamp
                let base = summaryMessage(for: order)
                let preparedAtText = order.preparedAt.map { dateFormatter.string(from: $0) } ?? "—"
                var message = base + "\n\n✅ Prepared at: \(preparedAtText)"

                // 2) If collected, append collected timestamp
                let sharedOrder = OrderManager.shared.ordersForKitchen[idx]
                if let collected = sharedOrder.collectedAt {
                    let collectedAtText = dateFormatter.string(from: collected)
                    message += "\n⏱ Collected at: \(collectedAtText)"
                }

                // 3) Create the alert
                let alert = UIAlertController(
                    title: "\(order.branchName) Details",
                    message: message,
                    preferredStyle: .alert
                )

                // 4) If *not* yet collected, allow undo
                if !sharedOrder.isCollected {
                    alert.addAction(UIAlertAction(title: "Undo Prepared", style: .destructive) { _ in
                        OrderManager.shared.unmarkPrepared(at: idx)
                        self.reloadOrders()
                    })
                }

                // 5) Always have an OK button to dismiss
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)

            default:
                break
        }
    }
}
