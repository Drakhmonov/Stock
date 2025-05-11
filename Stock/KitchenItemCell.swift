//
//  KitchenItemCell.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 10/05/2025.
//

import UIKit

class KitchenItemCell: UITableViewCell {

    var item: CustomStockItem! {
        didSet {
            nameLabel.text = item.name
            quantityLabel.text = "\(item.quantity)"
        }
    }

    let nameLabel = UILabel()
    let quantityLabel = UILabel()
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)

    var onQuantityChanged: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel.font = .systemFont(ofSize: 16)
        quantityLabel.font = .boldSystemFont(ofSize: 16)
        quantityLabel.textAlignment = .center
        minusButton.setTitle("−", for: .normal)
        plusButton.setTitle("+", for: .normal)

        [nameLabel, minusButton, quantityLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),

            quantityLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 30),

            minusButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -8),
            minusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30)
        ])

        minusButton.addTarget(self, action: #selector(decrease), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increase), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func increase() {
        item.quantity += 1
        quantityLabel.text = "\(item.quantity)"
        onQuantityChanged?(item.quantity)
    }

    @objc func decrease() {
        if item.quantity > 0 {
            item.quantity -= 1
            quantityLabel.text = "\(item.quantity)"
            onQuantityChanged?(item.quantity)
        }
    }
}
