//
//  DeliveryOrderCardCell.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 12/05/2025.
//

import UIKit

class DeliveryOrderCardCell: UITableViewCell {
    static let reuseIdentifier = "DeliveryOrderCardCell"

    private let container = UIView()
    private let branchLabel = UILabel()
    private let badgeLabel  = UILabel()
    private let itemsLabel  = UILabel()
    private let noteLabel   = UILabel()
    private let timeLabel   = UILabel()
    private let chevron     = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        // Container styling
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.layer.shadowColor   = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowOffset  = .init(width: 0, height: 2)
        container.layer.shadowRadius  = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        // Subviews
        [branchLabel, badgeLabel, itemsLabel, noteLabel, timeLabel, chevron].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }

        branchLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.masksToBounds = true

        itemsLabel.font = .systemFont(ofSize: 14)
        itemsLabel.numberOfLines = 0

        noteLabel.font = .italicSystemFont(ofSize: 13)
        noteLabel.numberOfLines = 2
        noteLabel.textColor = .systemGray

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray2

        chevron.tintColor = .systemGray3

        // Layout
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            branchLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            branchLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),

            badgeLabel.centerYAnchor.constraint(equalTo: branchLabel.centerYAnchor),
            badgeLabel.leadingAnchor.constraint(equalTo: branchLabel.trailingAnchor, constant: 8),

            chevron.centerYAnchor.constraint(equalTo: branchLabel.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            chevron.widthAnchor.constraint(equalToConstant: 12),

            itemsLabel.topAnchor.constraint(equalTo: branchLabel.bottomAnchor, constant: 8),
            itemsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            itemsLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            noteLabel.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor, constant: 4),
            noteLabel.leadingAnchor.constraint(equalTo: itemsLabel.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: itemsLabel.trailingAnchor),

            timeLabel.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: itemsLabel.leadingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with order: PlacedOrder, dateFormatter: DateFormatter) {
        branchLabel.text = order.branchName

        // Badge
        let (text, color): (String, UIColor) = {
            if order.isDelivered  { return ("Delivered", .systemGreen) }
            if order.isCollected  { return ("Collected", .systemOrange) }
            return ("Pending", .systemBlue)
        }()
        badgeLabel.text = " \(text) "
        badgeLabel.backgroundColor = color.withAlphaComponent(0.1)
        badgeLabel.textColor = color

        // Items summary
        let items = (order.preparedItems ?? order.items)
            .map { "\($0.quantity)x \($0.name)" }
        itemsLabel.text = items.prefix(2).joined(separator: ", ")
            + (items.count > 2 ? "…" : "")

        // Kitchen note
        if let note = order.kitchenNote, !note.isEmpty {
            noteLabel.text = "📩 \(note)"
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }

        // Times
        var times = [String]()
        if let preparedAt = order.preparedAt {
            times.append("Prep: \(dateFormatter.string(from: preparedAt))")
        }
        if let collectedAt = order.collectedAt {
            times.append("Coll: \(dateFormatter.string(from: collectedAt))")
        }
        if let deliveredAt = order.deliveredAt {
            times.append("Del: \(dateFormatter.string(from: deliveredAt))")
        }
        timeLabel.text = times.joined(separator: " • ")
    }
}
