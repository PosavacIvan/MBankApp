import UIKit

class HomeViewController: UIViewController {

    private var cards: [BankCard] = [] // kartice učitane iz baze

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "power"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
        setupLayout()
        loadCards()
    }

    private func setupLayout() {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let titleLabel = UILabel()
        titleLabel.text = "Accounts"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        logoutButton.setImage(UIImage(systemName: "power"), for: .normal)
        logoutButton.tintColor = .label
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        header.addSubview(titleLabel)
        header.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            header.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            logoutButton.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
    }

    private func loadCards() {
        // Za sada prazno, kasnije dohvati iz baze
        cards = [] // ako je prazno, prikazat će se prazan ekran
        tableView.reloadData()
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Odjava", message: "Jeste li sigurni da se želite odjaviti?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ne", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Da, odjavi me", style: .destructive, handler: { _ in
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
        }))

        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as? CardCell else {
            return UITableViewCell()
        }
        cell.configure(with: cards[indexPath.row])
        return cell
    }
}
