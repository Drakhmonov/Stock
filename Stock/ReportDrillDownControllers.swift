//
//  ReportDrillDownControllers.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 13/05/2025.
//

import UIKit

// MARK: - Branch Usage Models

struct BranchUsage {
    let branchName: String
    let totalItems: Int
}

struct ItemUsage {
    let name: String
    let quantity: Int
}

// MARK: - Branch Usage View Controller

/// Allows toggling between Ordered and Delivered consumption per branch.
class BranchUsageViewController: UIViewController {
    private enum UsageType: Int {
        case ordered = 0, delivered
        var title: String {
            switch self {
            case .ordered: return "Ordered"
            case .delivered: return "Delivered"
            }
        }
    }

    private let orderedUsage: [String: [String: Int]]
    private let deliveredUsage: [String: [String: Int]]
    private var currentUsageType: UsageType = .ordered

    private var branches: [BranchUsage] = []
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [UsageType.ordered.title, UsageType.delivered.title])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// - Parameters:
    ///   - ordered: mapping branch → item quantities ordered in interval
    ///   - delivered: mapping branch → item quantities delivered in interval
    init(ordered: [String: [String: Int]], delivered: [String: [String: Int]]) {
        self.orderedUsage = ordered
        self.deliveredUsage = delivered
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Branch Consumption"
        view.backgroundColor = .systemBackground

        setupSegmentControl()
        setupTableView()
        loadBranches()
    }

    private func setupSegmentControl() {
        segmentControl.addTarget(self, action: #selector(usageTypeChanged), for: .valueChanged)
        navigationItem.titleView = segmentControl
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BranchUsageCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func usageTypeChanged() {
        if let selected = UsageType(rawValue: segmentControl.selectedSegmentIndex) {
            currentUsageType = selected
            loadBranches()
        }
    }

    private func loadBranches() {
        let raw = (currentUsageType == .ordered) ? orderedUsage : deliveredUsage
        branches = raw.map { branch, items in
            BranchUsage(branchName: branch, totalItems: items.values.reduce(0, +))
        }
        .sorted { $0.branchName < $1.branchName }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension BranchUsageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        branches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BranchUsageCell", for: indexPath)
        let usage = branches[indexPath.row]
        cell.textLabel?.text = "🍽️ \(usage.branchName): \(usage.totalItems)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let usage = branches[indexPath.row]
        let rawDict = (currentUsageType == .ordered) ? orderedUsage : deliveredUsage
        let items = rawDict[usage.branchName]?
            .map { ItemUsage(name: $0.key, quantity: $0.value) }
            ?? []
        let detailVC = BranchItemDetailViewController(branchName: usage.branchName, items: items)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Item Usage Detail View Controller

class BranchItemDetailViewController: UIViewController {
    private let branchName: String
    private let items: [ItemUsage]
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(branchName: String, items: [ItemUsage]) {
        self.branchName = branchName
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = branchName
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemUsageCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension BranchItemDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemUsageCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = "• \(item.name): \(item.quantity)"
        return cell
    }
}
