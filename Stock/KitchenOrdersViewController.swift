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

    /// Tracks which sections are collapsed
    private var collapsedSections = Set<Int>()

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
        tableView.register(
            KitchenOrderCardCell.self,
            forCellReuseIdentifier: KitchenOrderCardCell.reuseIdentifier
        )
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

        pendingLabel.text   = "🕒 Pending: \(pendingOrders.count)"
        preparingLabel.text = "🔧 Preparing: \(preparingOrders.count)"
        preparedLabel.text  = "✅ Prepared: \(preparedOrders.count)"

        tableView.reloadData()
    }

    // MARK: – Helper

    /// Multiline summary of items + branch note
    private func summaryMessage(for order: PlacedOrder) -> String {
        let itemsText = order.items
            .map { "• \($0.quantity)x \($0.name)" }
            .joined(separator: "\n")

        let noteText: String
        if let note = order.kitchenNote,
           !note.trimmingCharacters(in: .whitespaces).isEmpty {
            noteText = "\n\n📩 Note: \(note)"
        } else {
            noteText = ""
        }

        return itemsText + noteText
    }

    // MARK: – UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsedSections.contains(section) { return 0 }
        switch section {
        case 0: return pendingOrders.count
        case 1: return preparingOrders.count
        default: return preparedOrders.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .center
        header.distribution = .equalSpacing
        header.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        header.isLayoutMarginsRelativeArrangement = true
        header.backgroundColor = .secondarySystemBackground
        header.tag = section

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        switch section {
        case 0: titleLabel.text = "🕒 Pending Orders"
        case 1: titleLabel.text = "🔧 Preparing Orders"
        default: titleLabel.text = "✅ Prepared Orders"
        }

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray
        let angle: CGFloat = collapsedSections.contains(section) ? -.pi/2 : 0
        chevron.transform = CGAffineTransform(rotationAngle: angle)

        header.addArrangedSubview(titleLabel)
        header.addArrangedSubview(chevron)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
        header.addGestureRecognizer(tap)

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order: PlacedOrder = {
            switch indexPath.section {
            case 0: return pendingOrders[indexPath.row]
            case 1: return preparingOrders[indexPath.row]
            default: return preparedOrders[indexPath.row]
            }
        }()

        let cell = tableView.dequeueReusableCell(
            withIdentifier: KitchenOrderCardCell.reuseIdentifier,
            for: indexPath
        ) as! KitchenOrderCardCell
        cell.configure(with: order, dateFormatter: dateFormatter)
        return cell
    }

    // MARK: – UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = pendingOrders[indexPath.row]
        case 1: order = preparingOrders[indexPath.row]
        default: order = preparedOrders[indexPath.row]
        }

        guard let idx = OrderManager.shared.ordersForKitchen.firstIndex(where: {
            $0.branchName == order.branchName && $0.placedAt == order.placedAt
        }) else { return }

        switch indexPath.section {
        case 0:
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
            let prepareVC = PrepareOrderViewController(orderIndex: idx, order: order)
            navigationController?.pushViewController(prepareVC, animated: true)

        case 2:
            let shared = OrderManager.shared.ordersForKitchen[idx]
            var message = summaryMessage(for: order)
            if let preparedAt = shared.preparedAt {
                message += "\n\n✅ Prepared at: \(dateFormatter.string(from: preparedAt))"
            }
            if shared.isCollected {
                if let collectedAt = shared.collectedAt {
                    message += "\n⏱ Collected at: \(dateFormatter.string(from: collectedAt))"
                }
                // Show details only
                let info = UIAlertController(
                    title: "\(order.branchName) Prepared",
                    message: message,
                    preferredStyle: .alert
                )
                info.addAction(UIAlertAction(title: "OK", style: .default))
                present(info, animated: true)
            } else {
                // Allow undo if not collected
                let undoAlert = UIAlertController(
                    title: "\(order.branchName) Prepared",
                    message: message,
                    preferredStyle: .alert
                )
                undoAlert.addAction(UIAlertAction(title: "Undo Prepared", style: .destructive) { _ in
                    OrderManager.shared.unmarkPrepared(at: idx)
                    self.reloadOrders()
                })
                undoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(undoAlert, animated: true)
            }

        default:
            break
        }
    }

    // MARK: – Section Collapse

    @objc private func toggleSection(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        if collapsedSections.contains(section) {
            collapsedSections.remove(section)
        } else {
            collapsedSections.insert(section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}
