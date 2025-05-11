//
//  PrepareItemCell.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//

import UIKit

class PrepareItemCell: UITableViewCell {

    let nameLabel = UILabel()
    let orderedLabel = UILabel()
    let quantityLabel = UILabel()
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)

    var onQuantityChanged: ((Int) -> Void)?
    private var currentQuantity = 0
    private var maxQuantity = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        orderedLabel.font = .systemFont(ofSize: 14)
        orderedLabel.textColor = .gray
        quantityLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true

        minusButton.setTitle("–", for: .normal)
        plusButton.setTitle("+", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 22)
        plusButton.titleLabel?.font = .systemFont(ofSize: 22)

        minusButton.addTarget(self, action: #selector(decrease), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increase), for: .touchUpInside)

        let qtyStack = UIStackView(arrangedSubviews: [minusButton, quantityLabel, plusButton])
        qtyStack.axis = .horizontal
        qtyStack.spacing = 10

        let labelStack = UIStackView(arrangedSubviews: [nameLabel, orderedLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4

        let fullStack = UIStackView(arrangedSubviews: [labelStack, qtyStack])
        fullStack.axis = .horizontal
        fullStack.spacing = 12
        fullStack.alignment = .center
        fullStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(fullStack)

        NSLayoutConstraint.activate([
            fullStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fullStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            fullStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            fullStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, ordered: Int, current: Int, max: Int) {
        nameLabel.text = name
        orderedLabel.text = "Ordered: \(ordered)"
        quantityLabel.text = "\(current)"
        currentQuantity = current
        maxQuantity = max
    }

    @objc func increase() {
        if currentQuantity < maxQuantity {
            currentQuantity += 1
            quantityLabel.text = "\(currentQuantity)"
            onQuantityChanged?(currentQuantity)
        }
    }

    @objc func decrease() {
        if currentQuantity > 0 {
            currentQuantity -= 1
            quantityLabel.text = "\(currentQuantity)"
            onQuantityChanged?(currentQuantity)
        }
    }
}
