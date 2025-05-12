//
//  PrepareOrderViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import UIKit

class PrepareOrderViewController: UIViewController {

    // MARK: – Data

    private let orderIndex: Int
    private var order: PlacedOrder
    private var quantitiesToPrepare: [String: Int]

    // MARK: – UI

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let noteTextView = UITextView()
    private let sendButton = UIButton(type: .system)

    // MARK: – Init

    init(orderIndex: Int, order: PlacedOrder) {
        self.orderIndex = orderIndex
        self.order = order
        self.quantitiesToPrepare = Dictionary(
            uniqueKeysWithValues: order.items.map { ($0.name, 0) }
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prepare Order"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupNoteTextView()
        setupSendButton()

        // Dismiss keyboard on background tap
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: – Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Register cells
        tableView.register(
            PrepareItemCell.self,
            forCellReuseIdentifier: PrepareItemCell.reuseIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "NoteCell"
        )

        // Footer contains the send button
        tableView.tableFooterView = makeFooterView()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            // Automatically moves above keyboard
            tableView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    private func setupNoteTextView() {
        noteTextView.delegate = self
        noteTextView.font = .systemFont(ofSize: 16)
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = UIColor.lightGray.cgColor
        noteTextView.layer.cornerRadius = 8
        noteTextView.text = "Enter a note..."
        noteTextView.textColor = .lightGray
    }

    private func setupSendButton() {
        sendButton.setTitle("✅ Send to Delivery", for: .normal)
        sendButton.backgroundColor = .systemGreen
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        sendButton.layer.cornerRadius = 10
        sendButton.addTarget(
            self,
            action: #selector(sendToDelivery),
            for: .touchUpInside
        )
    }

    private func makeFooterView() -> UIView {
        let footer = UIView(frame: CGRect(
            x: 0, y: 0,
            width: view.bounds.width,
            height: 80
        ))
        footer.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(
                equalTo: footer.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(
                equalTo: footer.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(
                equalTo: footer.centerYAnchor),
            sendButton.heightAnchor.constraint(
                equalToConstant: 50)
        ])
        return footer
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: – Submit

    @objc private func sendToDelivery() {
        let preparedItems: [CustomStockItem] = order.items.compactMap {
            let qty = quantitiesToPrepare[$0.name] ?? 0
            return qty > 0
                ? CustomStockItem(name: $0.name, quantity: qty)
                : nil
        }

        guard !preparedItems.isEmpty else {
            let alert = UIAlertController(
                title: "No Items Prepared",
                message: "Please select at least one item to send.",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let raw = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = (raw == "Enter a note...") ? "" : raw

        var kitchenOrder = OrderManager.shared.ordersForKitchen[orderIndex]
        kitchenOrder.isPrepared    = true
        kitchenOrder.preparedAt    = Date()
        kitchenOrder.preparedItems = preparedItems
        kitchenOrder.kitchenNote   = note
        OrderManager.shared.ordersForKitchen[orderIndex] = kitchenOrder

        let alert = UIAlertController(
            title: "Order Sent ✅",
            message: "The order has been sent to delivery.",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: – UITableViewDataSource & Delegate

extension PrepareOrderViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? order.items.count : 1
    }

    func tableView(_ tv: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Items" : "Note"
    }

    func tableView(_ tv: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell = tv.dequeueReusableCell(
                withIdentifier: PrepareItemCell.reuseIdentifier,
                for: indexPath
            ) as! PrepareItemCell
            let item = order.items[indexPath.row]
            let current = quantitiesToPrepare[item.name] ?? 0
            cell.configure(
                name: item.name,
                ordered: item.quantity,
                current: current,
                max: item.quantity
            )
            cell.onQuantityChanged = { [weak self] newQty in
                self?.quantitiesToPrepare[item.name] = newQty
            }
            return cell
        } else {
            let cell = tv.dequeueReusableCell(
                withIdentifier: "NoteCell",
                for: indexPath
            )
            cell.selectionStyle = .none
            if noteTextView.superview != cell.contentView {
                noteTextView.removeFromSuperview()
                cell.contentView.addSubview(noteTextView)
                noteTextView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    noteTextView.topAnchor.constraint(
                        equalTo: cell.contentView.topAnchor, constant: 8),
                    noteTextView.bottomAnchor.constraint(
                        equalTo: cell.contentView.bottomAnchor, constant: -8),
                    noteTextView.leadingAnchor.constraint(
                        equalTo: cell.contentView.leadingAnchor, constant: 16),
                    noteTextView.trailingAnchor.constraint(
                        equalTo: cell.contentView.trailingAnchor, constant: -16),
                    noteTextView.heightAnchor.constraint(
                        equalToConstant: 120)
                ])
            }
            return cell
        }
    }

    func tableView(_ tv: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return indexPath.section == 0 ? 60 : 140
    }
}

// MARK: – UITextViewDelegate (placeholder)

extension PrepareOrderViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ tv: UITextView) {
        if tv.textColor == .lightGray {
            tv.text = ""
            tv.textColor = .label
        }
    }
    func textViewDidEndEditing(_ tv: UITextView) {
        if tv.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tv.text = "Enter a note..."
            tv.textColor = .lightGray
        }
    }
}

