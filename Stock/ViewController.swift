//
//  ViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 08/05/2025.
//
import UIKit


class ViewController: UIViewController {
    
    let buttonsData: [(title: String, emoji: String, selector: Selector)] = [
        ("Regent's Street", "🍽️", #selector(regentsStreetTapped)),
        ("Seven Dials Market", "🍽️", #selector(sevenDialsTapped)),
        ("Mercato Metropolitano", "🍽️", #selector(mercatoTapped)),
        ("Brent Cross", "🍽️", #selector(brentCrossTapped)),
        ("Central Kitchen", "🏬", #selector(stockTapped)),
        ("Delivery", "🚚", #selector(deliveryTapped))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupButtonsGrid()
    }

    func setupButtonsGrid() {
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        for i in stride(from: 0, to: buttonsData.count, by: 2) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 16

            for j in 0..<2 {
                if i + j < buttonsData.count {
                    let data = buttonsData[i + j]
                    let button = UIButton(type: .system)
                    button.setTitle("\(data.emoji)\n\(data.title)", for: .normal)
                    button.titleLabel?.numberOfLines = 2
                    button.titleLabel?.textAlignment = .center
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                    button.backgroundColor = UIColor.systemBlue
                    button.setTitleColor(.white, for: .normal)
                    button.layer.cornerRadius = 12
                    button.heightAnchor.constraint(equalToConstant: 100).isActive = true
                    button.addTarget(self, action: data.selector, for: .touchUpInside)
                    rowStack.addArrangedSubview(button)
                }
            }
            mainStack.addArrangedSubview(rowStack)
        }

        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Button Actions

        @objc func regentsStreetTapped() {
            let items = createItemsForBranch("Regent's Street")
            printOrder(items, branchName: "Regent's Street")
            let orderVC = OrderPageViewController(branchName: "Regent's Street", items: items)
            navigationController?.pushViewController(orderVC, animated: true)
        }

        @objc func sevenDialsTapped() {
            let items = createItemsForBranch("Seven Dials Market")
            printOrder(items, branchName: "Seven Dials Market")
            let orderVC = OrderPageViewController(branchName: "Seven Dials Market", items: items)
            navigationController?.pushViewController(orderVC, animated: true)
        }

        @objc func mercatoTapped() {
            let items = createItemsForBranch("Mercato Metropolitano")
            printOrder(items, branchName: "Mercato Metropolitano")
            let orderVC = OrderPageViewController(branchName: "Mercato Metropolitano", items: items)
            navigationController?.pushViewController(orderVC, animated: true)
        }

        @objc func brentCrossTapped() {
            let items = createItemsForBranch("Brent Cross")
            printOrder(items, branchName: "Brent Cross")
            let orderVC = OrderPageViewController(branchName: "Brent Cross", items: items)
            navigationController?.pushViewController(orderVC, animated: true)
        }

    @objc func stockTapped() {
        let kitchenVC = KitchenOrdersViewController() // ✅ this is correct
        navigationController?.pushViewController(kitchenVC, animated: true)
    }



        @objc func deliveryTapped() {
            let deliveryVC = DeliveryPageViewController()
            navigationController?.pushViewController(deliveryVC, animated: true)
        }
        
        // MARK: - Helper Methods
    func createItemsForBranch(_ branchName: String) -> [CustomStockItem] {
            return [
                CustomStockItem(name: "Beef dumplings (bag)", quantity: 0),
                CustomStockItem(name: "Chicken dumplings (bag)", quantity: 0),
                CustomStockItem(name: "Vegan dumplings (bag)", quantity: 0),
                CustomStockItem(name: "Chilli oil (box)", quantity: 0),
                CustomStockItem(name: "Rapeseed oil (container)", quantity: 0),
                CustomStockItem(name: "Parsley (bunch)", quantity: 0),
                CustomStockItem(name: "Yoghurt (basket)", quantity: 0),
                CustomStockItem(name: "Sour cream (basket)", quantity: 0),
                CustomStockItem(name: "Plate for 3 (box)", quantity: 0),
                CustomStockItem(name: "Plate for 5 (box)", quantity: 0),
                CustomStockItem(name: "Plate for Combo (box)", quantity: 0),
                CustomStockItem(name: "Take away box Small (box)", quantity: 0),
                CustomStockItem(name: "Take away box Combo (box)", quantity: 0),
                CustomStockItem(name: "Napkins (box)", quantity: 0),
                CustomStockItem(name: "Blue Roll (pack)", quantity: 0),
                CustomStockItem(name: "Take away bag (box)", quantity: 0),
                CustomStockItem(name: "Gloves L (box)", quantity: 0),
                CustomStockItem(name: "Vinegar (container)", quantity: 0),
                CustomStockItem(name: "Coriander seeds (pack)", quantity: 0),
                CustomStockItem(name: "Still water (pack)", quantity: 0),
                CustomStockItem(name: "Sparkling water (pack)", quantity: 0),
                CustomStockItem(name: "Soda drinks (pack)", quantity: 0)
            ]
        }

        // MARK: - Print Order

    func printOrder(_ items: [CustomStockItem], branchName: String) {
        print("Order for branch: \(branchName)")
        for item in items {
            print("Item: \(item.name), Quantity: \(item.quantity)")
        }
    }

}
