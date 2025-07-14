//
//  TransactionCellView.swift
//  MBankApp
//
//  Created by Ivan Posavac on 14.07.2025..
//

import UIKit

class TransactionCell: UITableViewCell {

    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Naziv transakcije (npr. ↑↑↑ Test)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label

        // Datum ispod naslova
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel

        // Iznos desno
        amountLabel.font = UIFont.boldSystemFont(ofSize: 16)
        amountLabel.textAlignment = .right

        // Lijevi stack: naslov + datum
        let leftStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        // Glavni horizontalni stack
        let mainStack = UIStackView(arrangedSubviews: [leftStack, amountLabel])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.alignment = .center
        mainStack.distribution = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with transaction: Transaction) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        titleLabel.text = transaction.title
        dateLabel.text = formatter.string(from: transaction.date)

        let amountText = String(format: "%.2f €", transaction.amount)
        amountLabel.text = amountText
        amountLabel.textColor = transaction.amount < 0 ? .systemRed : .systemGreen
    }
}
