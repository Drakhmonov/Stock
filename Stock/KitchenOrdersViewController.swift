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

    private let tableView = UITableView()

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
        view.backgroundColor = .white

        // 1) Configure summaryStack + labels
        [pendingLabel, preparingLabel, preparedLabel].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            summaryStack.addArrangedSubview($0)
        }
        view.addSubview(summaryStack)
        summaryStack.translatesAutoresizingMaskIntoConstraints = false

        // 2) Configure tableView
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // 3) Layout constraints
        NSLayoutConstraint.activate([
            // Summary bar at top
            summaryStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            summaryStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryStack.heightAnchor.constraint(equalToConstant: 30),

            // Table view below summary
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

        // Update summary labels
        pendingLabel.text   = "🕒 Pending: \(pendingOrders.count)"
        preparingLabel.text = "🔧 Preparing: \(preparingOrders.count)"
        preparedLabel.text  = "✅ Prepared: \(preparedOrders.count)"

        tableView.reloadData()
    }

    // MARK: – UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

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
        let orders: [PlacedOrder]
        switch indexPath.section {
            case 0: orders = pendingOrders
            case 1: orders = preparingOrders
            default: orders = preparedOrders
        }
        let order = orders[indexPath.row]

        var lines: [String] = order.items.map { "• \($0.name): \($0.quantity)" }
        if let note = order.kitchenNote, !note.isEmpty {
            lines.append("📩 Note: \(note)")
        }
        lines.append("🕓 Placed: \(dateFormatter.string(from: order.placedAt))")
        if indexPath.section == 1, let prepAt = order.preparingAt {
            lines.append("🔧 Preparing: \(dateFormatter.string(from: prepAt))")
        }
        if indexPath.section == 2, let preparedAt = order.preparedAt {
            lines.append("✅ Prepared: \(dateFormatter.string(from: preparedAt))")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.text = "\(order.branchName)\n" + lines.joined(separator: "\n")
        return cell
    }

    // MARK: – UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let orders: [PlacedOrder]
        switch indexPath.section {
            case 0: orders = pendingOrders
            case 1: orders = preparingOrders
            default: orders = preparedOrders
        }
        let order = orders[indexPath.row]

        guard let idx = OrderManager.shared.ordersForKitchen.firstIndex(where: {
            $0.branchName == order.branchName && $0.placedAt == order.placedAt
        }) else { return }

        switch indexPath.section {
        case 0:
            // Start preparing
            let alert = UIAlertController(title: "Start Preparing?",
                                          message: "Begin preparing \(order.branchName)'s order?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                OrderManager.shared.markOrderAsPreparing(at: idx)
                self.reloadOrders()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)

        case 1:
            // Go to detail (adjust quantities + note)
            let prepareVC = PrepareOrderViewController(orderIndex: idx, order: order)
            navigationController?.pushViewController(prepareVC, animated: true)

        case 2:
            // Undo prepared
            let alert = UIAlertController(title: "Undo Prepared?",
                                          message: "Mark \(order.branchName)'s order as not prepared?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                OrderManager.shared.unmarkPrepared(at: idx)
                self.reloadOrders()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)

        default:
            break
        }
    }
}
