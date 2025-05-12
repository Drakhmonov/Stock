//
//  PrepareItemCell.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 09/05/2025.
//
import UIKit

/// A table-view cell showing an item’s name, the “Ordered: X” subtitle,
/// and plus/minus buttons to pick how many to prepare.
class PrepareItemCell: UITableViewCell {

    static let reuseIdentifier = "PrepareItemCell"

    // MARK: UI Elements

    let nameLabel = UILabel()
    let orderedLabel = UILabel()
    let quantityLabel = UILabel()
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)

    /// Called whenever the user changes the quantity.
    var onQuantityChanged: ((Int) -> Void)?

    private var currentQuantity = 0
    private var maxQuantity = 0

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Name + ordered
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        orderedLabel.font = .systemFont(ofSize: 14)
        orderedLabel.textColor = .gray

        // Quantity display
        quantityLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true

        // Buttons
        minusButton.setTitle("–", for: .normal)
        plusButton.setTitle("+", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 22)
        plusButton.titleLabel?.font = .systemFont(ofSize: 22)
        minusButton.addTarget(self, action: #selector(decrease), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increase), for: .touchUpInside)

        // Stack them: [–] [count] [+]
        let qtyStack = UIStackView(arrangedSubviews: [minusButton, quantityLabel, plusButton])
        qtyStack.axis = .horizontal
        qtyStack.spacing = 10

        // Labels: name on top, ordered below
        let labelStack = UIStackView(arrangedSubviews: [nameLabel, orderedLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4

        // Full row: labels on left, qtyStack on right
        let fullStack = UIStackView(arrangedSubviews: [labelStack, qtyStack])
        fullStack.axis = .horizontal
        fullStack.alignment = .center
        fullStack.spacing = 12
        fullStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(fullStack)
        NSLayoutConstraint.activate([
            fullStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            fullStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            fullStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fullStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configuration

    /// Configure with item data.
    func configure(name: String, ordered: Int, current: Int, max: Int) {
        nameLabel.text = name
        orderedLabel.text = "Ordered: \(ordered)"
        currentQuantity = current
        maxQuantity = max
        quantityLabel.text = "\(current)"
    }

    // MARK: Actions

    @objc private func increase() {
        guard currentQuantity < maxQuantity else { return }
        currentQuantity += 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
    }

    @objc private func decrease() {
        guard currentQuantity > 0 else { return }
        currentQuantity -= 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
    }
}
