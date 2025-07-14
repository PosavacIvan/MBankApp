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
        setupNavigationBar()  // ✅ ključno za tri točkice
        loadTransactions()
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")

    }

    private func setupNavigationBar() {
        let optionsButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(showOptions)
        )
        navigationItem.rightBarButtonItem = optionsButton
    }

    @objc private func showOptions() {
        let alert = UIAlertController(title: "Opcije kartice", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Obriši karticu", style: .destructive, handler: { _ in
            self.deleteCard()
        }))
        alert.addAction(UIAlertAction(title: "Odustani", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }

    private func deleteCard() {
        DatabaseManager.shared.deleteCard(withIban: card.iban)
        navigationController?.popViewController(animated: true)
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

        // OVDE DODAJ!
        transactions.sort { $0.date > $1.date }

        tableView.reloadData()
    }
}

extension TransactionHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        cell.configure(with: transaction)
        return cell
    }
}

