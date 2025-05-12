//
//  BranchHistoryViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 11/05/2025.
//
import UIKit

class BranchHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()
    private let calendar = Calendar.current

    private let branchName: String
    private var orders: [PlacedOrder] = []
    private var todayOrders: [PlacedOrder] = []
    private var yesterdayOrders: [PlacedOrder] = []
    private var earlierOrders: [PlacedOrder] = []

    init(branchName: String) {
        self.branchName = branchName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(branchName) History"
        view.backgroundColor = .systemGroupedBackground

        configureTableView()
        loadAndGroupOrders()
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BranchHistoryCell.self, forCellReuseIdentifier: BranchHistoryCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadAndGroupOrders() {
        orders = OrderManager.shared.ordersForKitchen
            .filter { $0.branchName == branchName }
            .sorted { $0.placedAt > $1.placedAt }

        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        todayOrders = orders.filter { calendar.isDate($0.placedAt, inSameDayAs: today) }
        yesterdayOrders = orders.filter { calendar.isDate($0.placedAt, inSameDayAs: yesterday) }
        earlierOrders = orders.filter {
            !calendar.isDate($0.placedAt, inSameDayAs: today) &&
            !calendar.isDate($0.placedAt, inSameDayAs: yesterday)
        }

        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BranchHistoryCell.reuseIdentifier, for: indexPath) as? BranchHistoryCell else {
            return UITableViewCell()
        }

        let order: PlacedOrder
        switch indexPath.section {
        case 0: order = todayOrders[indexPath.row]
        case 1: order = yesterdayOrders[indexPath.row]
        default: order = earlierOrders[indexPath.row]
        }

        cell.configure(with: order, dateFormatter: dateFormatter)
        return cell
    }

    // MARK: - UITableViewDelegate
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
