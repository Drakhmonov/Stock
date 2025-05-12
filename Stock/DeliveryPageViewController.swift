//
//  DeliveryPageViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
// DeliveryPageViewController.swift

import UIKit

class DeliveryPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: – UI Components

    private let summaryStack   = UIStackView()
    private let pendingLabel   = UILabel()
    private let collectedLabel = UILabel()
    private let deliveredLabel = UILabel()
    private let tableView      = UITableView(frame: .zero, style: .grouped)

    // MARK: – Data

    private var pendingDelivery: [PlacedOrder] = []
    private var collectedOrders: [PlacedOrder] = []
    private var deliveredOrders: [PlacedOrder] = []

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
        title = "Delivery"
        view.backgroundColor = .systemBackground

        // Configure summary bar
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

        // Configure table view
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(
            DeliveryOrderCardCell.self,
            forCellReuseIdentifier: DeliveryOrderCardCell.reuseIdentifier
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Layout constraints
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

        pendingLabel.text   = "🚚 Pending: \(pendingDelivery.count)"
        collectedLabel.text = "📦 Collected: \(collectedOrders.count)"
        deliveredLabel.text = "✅ Delivered: \(deliveredOrders.count)"

        tableView.reloadData()
    }

    // MARK: – UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsedSections.contains(section) { return 0 }
        switch section {
        case 0: return pendingDelivery.count
        case 1: return collectedOrders.count
        default: return deliveredOrders.count
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
        case 0: titleLabel.text = "🚚 Pending Delivery"
        case 1: titleLabel.text = "📦 Order Collected"
        default: titleLabel.text = "✅ Delivered"
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
            case 0: return pendingDelivery[indexPath.row]
            case 1: return collectedOrders[indexPath.row]
            default: return deliveredOrders[indexPath.row]
            }
        }()

        let cell = tableView.dequeueReusableCell(
            withIdentifier: DeliveryOrderCardCell.reuseIdentifier,
            for: indexPath
        ) as! DeliveryOrderCardCell
        cell.configure(with: order, dateFormatter: dateFormatter)
        return cell
    }

    // MARK: – UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = pendingDelivery[indexPath.row]
        case 1: order = collectedOrders[indexPath.row]
        default: order = deliveredOrders[indexPath.row]
        }

        guard let idx = OrderManager.shared.ordersForKitchen.firstIndex(where: {
            $0.branchName == order.branchName && $0.placedAt == order.placedAt
        }) else { return }

        // Build detail message
        var message = summaryMessage(for: order)
        if let prep = order.preparedAt {
            message += "\n\n✅ Prepared: \(dateFormatter.string(from: prep))"
        }
        if let coll = order.collectedAt {
            message += "\n⏱ Collected: \(dateFormatter.string(from: coll))"
        }
        if let deliv = order.deliveredAt {
            message += "\n🏁 Delivered: \(dateFormatter.string(from: deliv))"
        }

        let alert = UIAlertController(
            title: "\(order.branchName) Details",
            message: message,
            preferredStyle: .alert
        )

        switch indexPath.section {
        case 0:
            alert.addAction(UIAlertAction(title: "✅ Collected", style: .default) { _ in
                OrderManager.shared.markOrderAsCollected(at: idx)
                self.reloadOrders()
            })
        case 1:
            alert.addAction(UIAlertAction(title: "✅ Delivered", style: .default) { _ in
                OrderManager.shared.markOrderAsDelivered(at: idx)
                self.reloadOrders()
            })
        case 2:
            // Delivered → allow undo
            alert.addAction(UIAlertAction(title: "Undo Delivered", style: .destructive) { _ in
                OrderManager.shared.unmarkDelivered(at: idx)
                self.reloadOrders()
            })
        default:
            break
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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

    // MARK: – Helpers

    private func summaryMessage(for order: PlacedOrder) -> String {
        let itemsText = (order.preparedItems ?? order.items)
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
}
