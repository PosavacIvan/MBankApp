import UIKit


enum TransferType {
    case own        // Vlastiti prijenos
    case external   // Novo plaćanje
}

class TransferViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let transferType: TransferType
    private var userCards: [BankCard] = []

    // MARK: - UI Elements

    private let fromCardLabel = UILabel()
    private let fromCardPicker = UIPickerView()

    private let toCardLabel = UILabel()
    private let toCardPicker = UIPickerView()

    private let ibanTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "IBAN primatelja"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .allCharacters
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Iznos (€)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Opis transakcije"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Pošalji", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(transferType: TransferType) {
        self.transferType = transferType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = transferType == .own ? "Vlastiti prijenos" : "Novo plaćanje"

        fromCardPicker.delegate = self
        fromCardPicker.dataSource = self

        toCardPicker.delegate = self
        toCardPicker.dataSource = self

        loadCards()
        setupUI()
        configureForTransferType()

        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }

    private func loadCards() {
        userCards = DatabaseManager.shared.getUserCards()
        fromCardPicker.reloadAllComponents()
        toCardPicker.reloadAllComponents()
    }

    // MARK: - UI Setup

    private func setupUI() {
        fromCardLabel.text = "S koje kartice"
        fromCardLabel.translatesAutoresizingMaskIntoConstraints = false
        toCardLabel.text = "Na koju karticu"
        toCardLabel.translatesAutoresizingMaskIntoConstraints = false

        fromCardPicker.translatesAutoresizingMaskIntoConstraints = false
        toCardPicker.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fromCardLabel)
        view.addSubview(fromCardPicker)

        if transferType == .own {
            view.addSubview(toCardLabel)
            view.addSubview(toCardPicker)
        } else {
            view.addSubview(ibanTextField)
        }

        view.addSubview(amountTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(sendButton)

        NSLayoutConstraint.activate([
            fromCardLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fromCardLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            fromCardPicker.topAnchor.constraint(equalTo: fromCardLabel.bottomAnchor, constant: 4),
            fromCardPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            fromCardPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            fromCardPicker.heightAnchor.constraint(equalToConstant: 100),
        ])

        if transferType == .own {
            NSLayoutConstraint.activate([
                toCardLabel.topAnchor.constraint(equalTo: fromCardPicker.bottomAnchor, constant: 16),
                toCardLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

                toCardPicker.topAnchor.constraint(equalTo: toCardLabel.bottomAnchor, constant: 4),
                toCardPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                toCardPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                toCardPicker.heightAnchor.constraint(equalToConstant: 100),

                amountTextField.topAnchor.constraint(equalTo: toCardPicker.bottomAnchor, constant: 24),
            ])
        } else {
            NSLayoutConstraint.activate([
                ibanTextField.topAnchor.constraint(equalTo: fromCardPicker.bottomAnchor, constant: 16),
                ibanTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                ibanTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                ibanTextField.heightAnchor.constraint(equalToConstant: 44),

                amountTextField.topAnchor.constraint(equalTo: ibanTextField.bottomAnchor, constant: 24),
            ])
        }

        NSLayoutConstraint.activate([
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),

            descriptionTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 12),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 44),

            sendButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 24),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func configureForTransferType() {
        ibanTextField.isHidden = (transferType == .own)
        toCardPicker.isHidden = (transferType == .external)
        toCardLabel.isHidden = (transferType == .external)
    }

    // MARK: - UIPickerView

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        userCards.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let card = userCards[row]
        return "\(card.name) ••••\(card.iban.suffix(4))"
    }

    // MARK: - Action

    @objc private func handleSend() {
        let fromCard = userCards[fromCardPicker.selectedRow(inComponent: 0)]

        var destination: String = ""
        var toCard: BankCard?

        if transferType == .own {
            toCard = userCards[toCardPicker.selectedRow(inComponent: 0)]
            destination = toCard?.iban ?? ""
            if fromCard.iban == destination {
                showAlert("Ne možete slati na istu karticu.")
                return
            }
        } else {
            guard let iban = ibanTextField.text, !iban.isEmpty else {
                showAlert("Unesite IBAN primatelja.")
                return
            }
            destination = iban
        }

        guard let amountText = amountTextField.text,
              let amount = Double(amountText), amount > 0 else {
            showAlert("Unesite ispravan iznos.")
            return
        }

        guard amount <= fromCard.balance else {
            showAlert("Nemate dovoljno sredstava.")
            return
        }

        let description = descriptionTextField.text ?? ""
        let now = Date()

        // 1. Dodaj izlaznu transakciju
        let outgoingTx = Transaction(
            id: 0,
            title: "↑↑↑ \(description)",
            amount: -amount,
            date: now,
            cardIban: fromCard.iban
        )
        DatabaseManager.shared.addTransaction(outgoingTx)
        DatabaseManager.shared.updateBalance(for: fromCard.iban, newBalance: fromCard.balance - amount)

        // 2. Ako primatelj postoji među korisnikovim karticama
        if let toCard = userCards.first(where: { $0.iban == destination }) {
            let incomingTx = Transaction(
                id: 0,
                title: "↓↓↓ \(description)",
                amount: amount,
                date: now,
                cardIban: toCard.iban
            )
            DatabaseManager.shared.addTransaction(incomingTx)
            DatabaseManager.shared.updateBalance(for: toCard.iban, newBalance: toCard.balance + amount)
        }

        showAlert("Transakcija uspješna.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(_ message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default) { _ in
            onDismiss?()
        })
        present(alert, animated: true)
    }
}

