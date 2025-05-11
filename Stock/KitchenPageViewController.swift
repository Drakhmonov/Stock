//
//  KitchenPageViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//

import UIKit

class KitchenPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Central Kitchen"
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return OrderManager.shared.ordersForKitchen.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let order = OrderManager.shared.ordersForKitchen[section]
        let hasNote = !(order.kitchenNote?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        return order.items.count + (hasNote ? 2 : 1) // Items + optional note + footer
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let order = OrderManager.shared.ordersForKitchen[section]
        return order.branchName + (order.isPrepared ? " ✅" : "")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = OrderManager.shared.ordersForKitchen[indexPath.section]
        let hasNote = !(order.kitchenNote?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)

        if indexPath.row < order.items.count {
            // Item row
            let item = order.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
            cell.textLabel?.text = "• \(item.name): \(item.quantity)"
            return cell

        } else if hasNote && indexPath.row == order.items.count {
            // Dedicated note cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            if let note = order.kitchenNote {
                cell.textLabel?.text = "📩 Note from Branch:\n\"\(note)\""
                cell.textLabel?.font = .italicSystemFont(ofSize: 15)
                cell.textLabel?.numberOfLines = 0
            }
            return cell

        } else {
            // Footer cell with timestamps and button
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.selectionStyle = .none

            let placedText = "🕓 Placed: \(dateFormatter.string(from: order.placedAt))"
            var detail = placedText

            if order.isPrepared, let preparedAt = order.preparedAt {
                detail += "\n✅ Prepared: \(dateFormatter.string(from: preparedAt))"
            }

            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = detail
            cell.detailTextLabel?.font = .systemFont(ofSize: 14)

            if !order.isPrepared {
                let button = UIButton(type: .system)
                button.setTitle("✅ Mark as Prepared", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .systemGreen
                button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
                button.layer.cornerRadius = 8
                button.tag = indexPath.section
                button.addTarget(self, action: #selector(markAsPrepared(_:)), for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false

                cell.contentView.addSubview(button)
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: cell.detailTextLabel!.bottomAnchor, constant: 8),
                    button.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    button.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    button.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
                    button.heightAnchor.constraint(equalToConstant: 44)
                ])
            }

            return cell
        }
    }

    @objc func markAsPrepared(_ sender: UIButton) {
        let section = sender.tag
        OrderManager.shared.markOrderAsPrepared(at: section)
        tableView.reloadData()
    }
}
