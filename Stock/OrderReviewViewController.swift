//
//  OrderReviewViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import UIKit

class OrderReviewViewController: UIViewController, UITableViewDataSource {

    private let branchName: String
    private let items: [CustomStockItem]
    private let note: String
    private let onConfirm: () -> Void

    private let tableView = UITableView()

    init(branchName: String, items: [CustomStockItem], note: String, onConfirm: @escaping () -> Void) {
        self.branchName = branchName
        self.items = items
        self.note = note
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review Order"
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("✅ Confirm & Submit", for: .normal)
        confirmButton.backgroundColor = .systemGreen
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 10
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let editButton = UIButton(type: .system)
        editButton.setTitle("✏️ Go Back & Edit", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        view.addSubview(confirmButton)
        view.addSubview(editButton)

        var bottomAnchor: NSLayoutYAxisAnchor = confirmButton.topAnchor

        if !note.isEmpty {
            let noteLabel = UILabel()
            noteLabel.font = .italicSystemFont(ofSize: 16)
            noteLabel.textColor = .darkGray
            noteLabel.numberOfLines = 0
            noteLabel.text = "📩 Note: \(note)"
            noteLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(noteLabel)

            NSLayoutConstraint.activate([
                noteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                noteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                noteLabel.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -10)
            ])

            bottomAnchor = noteLabel.topAnchor
        }

        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),

            editButton.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -10),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    @objc private func confirmTapped() {
        onConfirm()
    }

    @objc private func editTapped() {
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        cell.textLabel?.text = "\(item.name): \(item.quantity)"
        return cell
    }
}
