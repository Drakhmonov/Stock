//
//  OrderPageViewController.swift.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import UIKit

class OrderPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var branchName: String
    var items: [CustomStockItem]

    init(branchName: String, items: [CustomStockItem]) {
        self.branchName = branchName
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var tableView: UITableView!
    let noteTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "\(branchName) Order"

        // Setup table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StockItemCell.self, forCellReuseIdentifier: "StockItemCell")
        view.addSubview(tableView)

        // Note TextView
        noteTextView.font = UIFont.systemFont(ofSize: 16)
        noteTextView.layer.borderColor = UIColor.lightGray.cgColor
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.cornerRadius = 8
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        noteTextView.text = ""
        view.addSubview(noteTextView)

        // Setup review button
        let reviewButton = UIButton(type: .system)
        reviewButton.setTitle("📝 Review Order", for: .normal)
        reviewButton.backgroundColor = .systemBlue
        reviewButton.setTitleColor(.white, for: .normal)
        reviewButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        reviewButton.layer.cornerRadius = 10
        reviewButton.translatesAutoresizingMaskIntoConstraints = false
        reviewButton.addTarget(self, action: #selector(reviewOrder), for: .touchUpInside)
        view.addSubview(reviewButton)
        
        // History Button setup:
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "clock.arrow.circlepath"),
            style: .plain,
            target: self,
            action: #selector(viewHistory)
        )



        // Layout constraints
        NSLayoutConstraint.activate([
            reviewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            reviewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reviewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reviewButton.heightAnchor.constraint(equalToConstant: 50),

            noteTextView.bottomAnchor.constraint(equalTo: reviewButton.topAnchor, constant: -10),
            noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: noteTextView.topAnchor, constant: -10)
        ])

        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

        // Tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func reviewOrder() {
        let orderedItems = items.filter { $0.quantity > 0 }

        if orderedItems.isEmpty {
            let alert = UIAlertController(title: "No Items Selected", message: "Please enter quantities before reviewing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        

        let note = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let reviewVC = OrderReviewViewController(branchName: branchName, items: orderedItems, note: note) {
            OrderManager.shared.addOrder(branchName: self.branchName, items: orderedItems, note: note)
            self.navigationController?.popToRootViewController(animated: true)
        }

        navigationController?.pushViewController(reviewVC, animated: true)
    }

    
    @objc private func viewHistory() {
      let historyVC = BranchHistoryViewController(branchName: branchName)
      navigationController?.pushViewController(historyVC, animated: true)
    }

    // MARK: - Keyboard Handling

    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let bottomInset = keyboardHeight - view.safeAreaInsets.bottom

        self.view.frame.origin.y = -bottomInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockItemCell", for: indexPath) as! StockItemCell
        let item = items[indexPath.row]
        cell.stockItem = item

        cell.onQuantityChanged = { [weak self] newQuantity in
            self?.items[indexPath.row].quantity = newQuantity
        }

        return cell
    }
}
