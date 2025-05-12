//
//  BranchOrderDetailViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 11/05/2025.
//
// BranchOrderDetailViewController.swift

import UIKit

class BranchOrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let order: PlacedOrder
    private let tableView = UITableView(frame: .zero, style: .grouped)

    // Icon mapping for steps
    private let steps: [(title: String, dateProvider: (PlacedOrder) -> Date?, imageName: String)] = [
        ("Placed",    { $0.placedAt },    "clock"),
        ("Prepared",  { $0.preparedAt },  "hammer"),
        ("Collected", { $0.collectedAt }, "cart"),
        ("Delivered", { $0.deliveredAt }, "checkmark")
    ]

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()

    init(order: PlacedOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(order.branchName) Details"
        view.backgroundColor = .systemBackground

        // 1) TableView setup
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // 2) Register a basic cell (we customize in code)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")

        // 3) Build and assign the timeline as tableHeaderView
        let header = makeTimelineHeader()
        // must set a frame height—240 is enough for 4 steps + spacing
        header.frame = CGRect(x: 0, y: 0,
                              width: view.bounds.width,
                              height: 240)
        tableView.tableHeaderView = header
    }

    // MARK: – Build Timeline Header

    private func makeTimelineHeader() -> UIView {
        // Vertical stack in a container
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 0
        container.alignment = .leading
        container.backgroundColor = .systemBackground

        for (index, step) in steps.enumerated() {
            // 1) Row with icon + title + timestamp
            let icon = UIImageView(image: UIImage(systemName: step.imageName))
            let date = step.dateProvider(order)
            icon.tintColor = date != nil ? .systemGreen : .quaternaryLabel
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 24).isActive = true

            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            if let date = date {
                label.text = "\(step.title): \(dateFormatter.string(from: date))"
            } else {
                label.text = "\(step.title): —"
                label.textColor = .quaternaryLabel
            }

            let row = UIStackView(arrangedSubviews: [icon, label])
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 8
            row.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
            row.isLayoutMarginsRelativeArrangement = true
            container.addArrangedSubview(row)

            // 2) Connector line (except after last step)
            if index < steps.count - 1 {
                let line = UIView()
                line.backgroundColor = .separator
                line.translatesAutoresizingMaskIntoConstraints = false
                line.heightAnchor.constraint(equalToConstant: 1).isActive = true
                container.addArrangedSubview(line)
            }
        }

        return container
    }

    // MARK: – UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        // 0: Items, 1: Notes
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // ordered + prepared
            let orderedCount = order.items.count
            let preparedCount = (order.preparedItems ?? []).count
            // Show header row + ordered items + (if any) a sub-header + prepared items
            return orderedCount + (preparedCount > 0 ? preparedCount + 1 : 0)
        case 1:
            // branch note + kitchen note (if present)
            var count = 0
            if let branchNote = order.kitchenNote, !branchNote.isEmpty { count += 1 }
            // if you have a separate branchNote field add here; otherwise skip
            return count
        default:
            return 0
        }
    }

    func tableView(_ tv: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Items" : "Notes"
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0

        if indexPath.section == 0 {
            // Items section
            let ordered = order.items
            let prepared = order.preparedItems ?? []

            // If there's prepared items, show a sub-header row before those
            // Rows 0..<ordered.count = ordered items
            if indexPath.row < ordered.count {
                let item = ordered[indexPath.row]
                cell.textLabel?.font = .systemFont(ofSize: 16)
                cell.textLabel?.text = "🔹 \(item.name): ordered \(item.quantity)"
            } else {
                // after ordered items
                let prepIndex = indexPath.row - ordered.count
                // if prepIndex == 0, it's the sub-header
                if prepIndex == 0 {
                    cell.textLabel?.font = .boldSystemFont(ofSize: 16)
                    cell.textLabel?.text = "Prepared to Send"
                } else {
                    let preparedItem = prepared[prepIndex - 1]
                    cell.textLabel?.font = .systemFont(ofSize: 16)
                    cell.textLabel?.text = "✅ \(preparedItem.name): \(preparedItem.quantity)"
                }
            }
        } else {
            // Notes section
            if let note = order.kitchenNote, !note.isEmpty {
                cell.textLabel?.font = .italicSystemFont(ofSize: 16)
                cell.textLabel?.text = "📩 \(note)"
            }
        }

        return cell
    }
}
