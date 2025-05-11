//
//  CardCell.swift
//  MBankApp
//
//  Created by Ivan Posavac on 07.05.2025..
//

import UIKit

class CardCell: UITableViewCell {

    private let nameLabel = UILabel()
    private let ibanLabel = UILabel()
    private let balanceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        clipsToBounds = true

        nameLabel.font = .boldSystemFont(ofSize: 18)
        ibanLabel.font = .systemFont(ofSize: 14)
        balanceLabel.font = .systemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [nameLabel, ibanLabel, balanceLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with card: BankCard) {
        nameLabel.text = card.name
        ibanLabel.text = card.iban
        balanceLabel.text = String(format: "%.2f EUR", card.balance)
    }
}
