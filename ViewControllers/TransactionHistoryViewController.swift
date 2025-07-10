//
//  TransactionHistoryViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 06.07.2025..
//


import UIKit

class TransactionHistoryViewController: UIViewController {

    private let card: BankCard
    private var transactions: [Transaction] = []

    private let tableView = UITableView()

    init(card: BankCard) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
        title = "Transakcije"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        loadTransactions()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadTransactions() {
        transactions = DatabaseManager.shared.getTransactions(forIban: card.iban)
        tableView.reloadData()
    }
}

extension TransactionHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(transaction.title)\n\(formatter.string(from: transaction.date)) - \(String(format: "%.2f", transaction.amount))€"
        return cell
    }
}
