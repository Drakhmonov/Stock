//
//  ReportDetailViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 13/05/2025.
//

import UIKit

/// Displays a list of orders underlying a selected report metric.
class ReportDetailViewController: UIViewController {
    private let metricTitle: String
    private let orders: [PlacedOrder]
    private let tableView = UITableView()
    
    init(metricTitle: String, orders: [PlacedOrder]) {
        self.metricTitle = metricTitle
        self.orders = orders
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = metricTitle
        view.backgroundColor = .systemBackground
        
        // Table setup
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailOrderCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ReportDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailOrderCell", for: indexPath)
        let order = orders[indexPath.row]
        // Display branch name and placed date; you can customize more details here
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        cell.textLabel?.numberOfLines = 0
        var text = "Branch: \(order.branchName)"
        text += "\nPlaced: \(df.string(from: order.placedAt))"
        if order.isPrepared, let prep = order.preparedAt {
            text += "\nPrepared: \(df.string(from: prep))"
        }
        if order.isCollected, let coll = order.collectedAt {
            text += "\nCollected: \(df.string(from: coll))"
        }
        if order.isDelivered, let del = order.deliveredAt {
            text += "\nDelivered: \(df.string(from: del))"
        }
        cell.textLabel?.text = text
        return cell
    }
}
