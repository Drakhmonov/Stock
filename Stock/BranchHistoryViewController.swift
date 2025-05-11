//
//  BranchHistoryViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 11/05/2025.
//
import UIKit

class BranchHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: – UI Components
    private let summaryStack = UIStackView()
    private let totalLabel = UILabel()
    private let deliveredLabel = UILabel()
    private let avgLabel = UILabel()
    private let tableView = UITableView()

    // MARK: – Data
    private let branchName: String
    private var orders: [PlacedOrder] = []
    private var todayOrders: [PlacedOrder] = []
    private var yesterdayOrders: [PlacedOrder] = []
    private var earlierOrders: [PlacedOrder] = []

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()
    private let calendar = Calendar.current

    // MARK: – Init
    init(branchName: String) {
        self.branchName = branchName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(branchName) History"
        view.backgroundColor = .white

        configureSummaryBar()
        configureTableView()
        loadAndGroupOrders()
    }

    // MARK: – Setup UI
    private func configureSummaryBar() {
        summaryStack.axis = .horizontal
        summaryStack.distribution = .equalSpacing
        summaryStack.alignment = .center
        summaryStack.spacing = 16

        [totalLabel, deliveredLabel, avgLabel].forEach { label in
            label.font = .systemFont(ofSize: 14, weight: .medium)
            summaryStack.addArrangedSubview(label)
        }

        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryStack)
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            summaryStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryStack.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: summaryStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: – Data Loading & Grouping
    private func loadAndGroupOrders() {
        // Filter and sort branch orders
        orders = OrderManager.shared.ordersForKitchen
            .filter { $0.branchName == branchName }
            .sorted { $0.placedAt > $1.placedAt }

        // Summary metrics
        let total = orders.count
        let deliveredCount = orders.filter { $0.isDelivered }.count
        let pct = total > 0 ? Int(Double(deliveredCount) / Double(total) * 100) : 0
        let avgItems = total > 0 ?
            Double(orders.map({ $0.items.count }).reduce(0, +)) / Double(total)
            : 0.0

        totalLabel.text   = "Total: \(total)"
        deliveredLabel.text = "Delivered: \(pct)%"
        avgLabel.text     = String(format: "Avg Items: %.1f", avgItems)

        // Chronological grouping
        todayOrders = []
        yesterdayOrders = []
        earlierOrders = []
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        for o in orders {
            if calendar.isDate(o.placedAt, inSameDayAs: today) {
                todayOrders.append(o)
            } else if calendar.isDate(o.placedAt, inSameDayAs: yesterday) {
                yesterdayOrders.append(o)
            } else {
                earlierOrders.append(o)
            }
        }

        tableView.reloadData()
    }

    // MARK: – UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return todayOrders.count
        case 1: return yesterdayOrders.count
        default: return earlierOrders.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return todayOrders.isEmpty     ? nil : "Today"
        case 1: return yesterdayOrders.isEmpty ? nil : "Yesterday"
        default: return earlierOrders.isEmpty   ? nil : "Earlier"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = todayOrders[indexPath.row]
        case 1: order = yesterdayOrders[indexPath.row]
        default: order = earlierOrders[indexPath.row]
        }

        let itemsSummary = order.items.map { "\($0.quantity)× \($0.name)" }
                                     .joined(separator: ", ")
        let status: String = {
            if order.isDelivered { return "Delivered" }
            if order.isCollected { return "Collected" }
            if order.isPrepared  { return "Prepared" }
            return "Pending"
        }()
        let deliveredAtText = order.deliveredAt.map {
            " • Delivered: \(dateFormatter.string(from: $0))"
        } ?? ""
        let noteSnippet = order.kitchenNote?.isEmpty == false
            ? " • Note: \(order.kitchenNote!)"
            : ""

        let text =
            "\(dateFormatter.string(from: order.placedAt))\n" +
            "\(itemsSummary)\n" +
            "Status: \(status)\(deliveredAtText)\(noteSnippet)"

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: – UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = todayOrders[indexPath.row]
        case 1: order = yesterdayOrders[indexPath.row]
        default: order = earlierOrders[indexPath.row]
        }
        let detailVC = BranchOrderDetailViewController(order: order)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
