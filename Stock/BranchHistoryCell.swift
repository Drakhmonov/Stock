//
//  BranchHistoryCell.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 12/05/2025.
//

import UIKit
// Custom cell with card style and status badge
class BranchHistoryCell: UITableViewCell {
    static let reuseIdentifier = "BranchHistoryCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel = UILabel()
    private let itemsLabel = UILabel()
    private let noteLabel = UILabel()
    private let statusBadge = UILabel()
    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(cardView)
        cardView.addSubview(dateLabel)
        cardView.addSubview(itemsLabel)
        cardView.addSubview(noteLabel)
        cardView.addSubview(statusBadge)
        cardView.addSubview(chevronImageView)
        
        // Configure labels
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textColor = .label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        itemsLabel.font = .systemFont(ofSize: 13)
        itemsLabel.textColor = .secondaryLabel
        itemsLabel.numberOfLines = 1
        itemsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noteLabel.font = .italicSystemFont(ofSize: 12)
        noteLabel.textColor = .tertiaryLabel
        noteLabel.numberOfLines = 1
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusBadge.font = .systemFont(ofSize: 12, weight: .medium)
        statusBadge.textColor = .white
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 10
        statusBadge.layer.masksToBounds = true
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -8),
            
            statusBadge.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            itemsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            itemsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            itemsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40),
            
            noteLabel.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor, constant: 4),
            noteLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            noteLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40),
            noteLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),
            
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with order: PlacedOrder, dateFormatter: DateFormatter) {
        dateLabel.text = dateFormatter.string(from: order.placedAt)
        let itemsSummary = order.items.map { "\($0.quantity)× \($0.name)" }
            .prefix(3)
            .joined(separator: ", ")
        itemsLabel.text = itemsSummary
        if let note = order.kitchenNote, !note.isEmpty {
            noteLabel.text = note
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }
        
        // Status
        let (text, color): (String, UIColor) = {
            if order.isDelivered { return ("Delivered", .systemGreen) }
            if order.isCollected { return ("Collected", .systemBlue) }
            if order.isPrepared  { return ("Prepared", .systemOrange) }
            return ("Pending", .systemGray)
        }()
        statusBadge.text = text
        statusBadge.backgroundColor = color
    }
}
