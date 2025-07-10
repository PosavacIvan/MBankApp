import UIKit

class CardView: UIView {

    private let nameLabel = UILabel()
    private let ibanLabel = UILabel()
    private let chipView = UIImageView()
    private let balanceLabel = UILabel() // Dodano za prikaz novca

    init(card: BankCard) {
        super.init(frame: .zero)
        setupUI(card: card)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(card: BankCard) {
        // 🎨 Boja kartice
        switch card.color {
        case "blue": backgroundColor = UIColor.systemBlue
        case "gray": backgroundColor = UIColor.systemGray
        case "black": backgroundColor = UIColor.black
        default: backgroundColor = UIColor.systemGray4
        }

        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        translatesAutoresizingMaskIntoConstraints = false

        // 🏷️ Naziv kartice
        nameLabel.text = card.name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // 💳 IBAN - zadnje 4
        ibanLabel.text = "•••• \(card.iban.suffix(4))"
        ibanLabel.textColor = .white
        ibanLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        ibanLabel.translatesAutoresizingMaskIntoConstraints = false

        // 🔲 Chip ikona
        chipView.image = UIImage(systemName: "creditcard.fill")
        chipView.tintColor = .white
        chipView.translatesAutoresizingMaskIntoConstraints = false

        // 💰 Balance (stanje)
        balanceLabel.text = "\(String(format: "%.2f", card.balance)) €"
        balanceLabel.textColor = .white
        balanceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false

        // ➕ Dodaj sve
        addSubview(nameLabel)
        addSubview(ibanLabel)
        addSubview(chipView)
        addSubview(balanceLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            chipView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            chipView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            chipView.widthAnchor.constraint(equalToConstant: 28),
            chipView.heightAnchor.constraint(equalToConstant: 20),

            ibanLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            ibanLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            balanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}

