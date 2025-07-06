import UIKit

class HomeViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Moje kartice"
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCards()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func loadCards() {
        // Ukloni stare kartice iz stacka
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let cards = DatabaseManager.shared.getUserCards()

        if cards.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Nemate dodanih kartica."
            emptyLabel.textAlignment = .center
            emptyLabel.font = .systemFont(ofSize: 18)
            emptyLabel.textColor = .secondaryLabel
            stackView.addArrangedSubview(emptyLabel)
        } else {
            for card in cards {
                let cardView = CardView(card: card)
                cardView.heightAnchor.constraint(equalToConstant: 160).isActive = true
                stackView.addArrangedSubview(cardView)
            }
        }
    }
}

