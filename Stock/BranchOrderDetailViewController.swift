//
//  BranchOrderDetailViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 11/05/2025.
//
import UIKit

class BranchOrderDetailViewController: UIViewController {

    private let order: PlacedOrder
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }()

    init(order: PlacedOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(order.branchName) Details"
        view.backgroundColor = .white

        setupLayout()
        populateDetails()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func populateDetails() {
        func addHeader(_ text: String) {
            let lbl = UILabel()
            lbl.text = text
            lbl.font = .systemFont(ofSize: 16, weight: .semibold)
            stack.addArrangedSubview(lbl)
        }
        func addValue(_ date: Date) {
            let lbl = UILabel()
            lbl.text = dateFormatter.string(from: date)
            stack.addArrangedSubview(lbl)
        }

        // Timeline
        addHeader("Placed at")
        addValue(order.placedAt)

        if let prepping = order.preparingAt {
            addHeader("Preparing started")
            addValue(prepping)
        }
        if let prepared = order.preparedAt {
            addHeader("Prepared at")
            addValue(prepared)
        }
        if let collected = order.collectedAt {
            addHeader("Collected at")
            addValue(collected)
        }
        if let delivered = order.deliveredAt {
            addHeader("Delivered at")
            addValue(delivered)
        }

        // Items breakdown
        addHeader("Items Ordered")
        for item in order.items {
            let lbl = UILabel()
            lbl.numberOfLines = 0
            lbl.text = "\(item.quantity) × \(item.name)"
            stack.addArrangedSubview(lbl)
        }
        if let preparedItems = order.preparedItems {
            addHeader("Prepared to Send")
            for item in preparedItems {
                let lbl = UILabel()
                lbl.numberOfLines = 0
                lbl.text = "\(item.quantity) × \(item.name)"
                stack.addArrangedSubview(lbl)
            }
        }

        // Notes
        if let branchNote = order.kitchenNote, !branchNote.isEmpty {
            addHeader("Kitchen Note")
            let lbl = UILabel()
            lbl.numberOfLines = 0
            lbl.text = branchNote
            stack.addArrangedSubview(lbl)
        }
    }
}
