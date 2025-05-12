//
//  PrepareOrderViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import UIKit

class PrepareOrderViewController: UIViewController, UITableViewDataSource, UITextViewDelegate {

    let orderIndex: Int
    var order: PlacedOrder

    var tableView = UITableView()
    var quantitiesToPrepare: [String: Int] = [:]

    let scrollView = UIScrollView()
    let contentStack = UIStackView()
    let noteTextView = UITextView()
    let sendButton = UIButton(type: .system)

    init(orderIndex: Int, order: PlacedOrder) {
        self.orderIndex = orderIndex
        self.order = order
        super.init(nibName: nil, bundle: nil)
        self.quantitiesToPrepare = Dictionary(uniqueKeysWithValues: order.items.map { ($0.name, 0) })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Prepare Order"

        setupLayout()
        setupKeyboardObservers()

        // Tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupLayout() {
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Stack view inside scroll view
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // Table view for item list
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(PrepareItemCell.self, forCellReuseIdentifier: "PrepareItemCell")
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(order.items.count * 60)).isActive = true
        contentStack.addArrangedSubview(tableView)

        // Note text view
        noteTextView.delegate = self
        noteTextView.font = .systemFont(ofSize: 16)
        noteTextView.layer.borderColor = UIColor.lightGray.cgColor
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.cornerRadius = 8
        noteTextView.text = ""
        noteTextView.textColor = .lightGray
        noteTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        contentStack.addArrangedSubview(noteTextView)

        // Send button
        sendButton.setTitle("✅ Send to Delivery", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = .systemGreen
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        sendButton.layer.cornerRadius = 10
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.addTarget(self, action: #selector(sendToDelivery), for: .touchUpInside)
        contentStack.addArrangedSubview(sendButton)
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = order.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrepareItemCell", for: indexPath) as! PrepareItemCell

        let currentQty = quantitiesToPrepare[item.name] ?? 0
        cell.configure(name: item.name, ordered: item.quantity, current: currentQty, max: item.quantity)

        cell.onQuantityChanged = { [weak self] newQty in
            self?.quantitiesToPrepare[item.name] = newQty
        }

        return cell
    }

    // MARK: - Keyboard + Tap Gesture

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = bottomInset + 20
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Placeholder Logic

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = ""
            textView.textColor = .lightGray
        }
    }

    // MARK: - Submit

    @objc func sendToDelivery() {
        let preparedItems: [CustomStockItem] = order.items.compactMap {
            let preparedQty = quantitiesToPrepare[$0.name] ?? 0
            return preparedQty > 0 ? CustomStockItem(name: $0.name, quantity: preparedQty) : nil
        }

        if preparedItems.isEmpty {
            let alert = UIAlertController(title: "No Items Prepared", message: "Please select at least one item to send.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        var note = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if note == "" { note = "" }

        OrderManager.shared.ordersForKitchen[orderIndex].isPrepared = true
        OrderManager.shared.ordersForKitchen[orderIndex].preparedAt = Date()
        OrderManager.shared.ordersForKitchen[orderIndex].preparedItems = preparedItems
        OrderManager.shared.ordersForKitchen[orderIndex].kitchenNote = note

        let alert = UIAlertController(title: "Order Sent ✅", message: "The order has been sent to delivery.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
