//
//  StockItemCell.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import UIKit

class StockItemCell: UITableViewCell {

    var stockItem: CustomStockItem! {
        didSet {
            nameLabel.text = stockItem.name
            quantityLabel.text = "\(stockItem.quantity)"
        }
    }

    var nameLabel: UILabel!
    var quantityLabel: UILabel!
    var minusButton: UIButton!
    var plusButton: UIButton!
    var onQuantityChanged: ((Int) -> Void)?


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        quantityLabel = UILabel()
        quantityLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        quantityLabel.textAlignment = .center
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false

        minusButton = UIButton(type: .system)
        minusButton.setTitle("–", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)

        plusButton = UIButton(type: .system)
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)

        contentView.addSubview(nameLabel)
        contentView.addSubview(minusButton)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(plusButton)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            quantityLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -10),
            quantityLabel.widthAnchor.constraint(equalToConstant: 40),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            minusButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -10),
            minusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func decreaseQuantity() {
        if stockItem.quantity > 0 {
            stockItem.quantity -= 1
            quantityLabel.text = "\(stockItem.quantity)"
            onQuantityChanged?(stockItem.quantity)
        }
    }

    @objc func increaseQuantity() {
        stockItem.quantity += 1
        quantityLabel.text = "\(stockItem.quantity)"
        onQuantityChanged?(stockItem.quantity)
    }

}
