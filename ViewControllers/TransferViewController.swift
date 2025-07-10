import UIKit

class TransferViewController: UIViewController {

    private var cards = DatabaseManager.shared.getUserCards()
    private var fromCard: BankCard?
    private var toCard: BankCard?

    private let fromPicker = UIPickerView()
    private let toPicker = UIPickerView()

    private let amountField = UITextField()
    private let descriptionField = UITextField()
    private let sendButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vlastiti prijenos"
        view.backgroundColor = .systemBackground

        fromCard = cards.first
        toCard = cards.count > 1 ? cards[1] : nil

        setupUI()

        fromPicker.delegate = self
        fromPicker.dataSource = self
        toPicker.delegate = self
        toPicker.dataSource = self
    }

    private func setupUI() {
        let fromLabel = makeLabel("S koje kartice")
        let toLabel = makeLabel("Na koju karticu")

        amountField.placeholder = "Iznos (€)"
        amountField.borderStyle = .roundedRect
        amountField.keyboardType = .decimalPad

        descriptionField.placeholder = "Opis transakcije"
        descriptionField.borderStyle = .roundedRect

        sendButton.setTitle("Pošalji", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 10
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        [fromLabel, fromPicker, toLabel, toPicker, amountField, descriptionField, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            fromLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fromLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            fromPicker.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 8),
            fromPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fromPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fromPicker.heightAnchor.constraint(equalToConstant: 80),

            toLabel.topAnchor.constraint(equalTo: fromPicker.bottomAnchor, constant: 20),
            toLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            toPicker.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 8),
            toPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toPicker.heightAnchor.constraint(equalToConstant: 80),

            amountField.topAnchor.constraint(equalTo: toPicker.bottomAnchor, constant: 30),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            descriptionField.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: amountField.leadingAnchor),
            descriptionField.trailingAnchor.constraint(equalTo: amountField.trailingAnchor),

            sendButton.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 40),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 200),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }

    @objc private func sendTapped() {
        guard let from = fromCard,
              let to = toCard,
              let amountText = amountField.text, let amount = Double(amountText),
              let desc = descriptionField.text, !desc.isEmpty else {
            showAlert("Molimo ispunite sva polja.")
            return
        }

        if from.iban == to.iban {
            showAlert("Odaberite različite kartice.")
            return
        }

        if amount <= 0 || amount > from.balance {
            showAlert("Nedovoljno sredstava.")
            return
        }

        let now = Date()

        let outgoing = Transaction(id: 0, title: "↑↑↑ \(desc)", amount: -amount, date: now, cardIban: from.iban)
        let incoming = Transaction(id: 0, title: "↓↓↓ \(desc)", amount: amount, date: now, cardIban: to.iban)

        DatabaseManager.shared.addTransaction(outgoing)
        DatabaseManager.shared.addTransaction(incoming)

        DatabaseManager.shared.updateBalance(for: from.iban, newBalance: from.balance - amount)
        DatabaseManager.shared.updateBalance(for: to.iban, newBalance: to.balance + amount)

        showAlert("Uspješan prijenos.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(_ msg: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onDismiss?() })
        present(alert, animated: true)
    }
}

extension TransferViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cards.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cards[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fromPicker {
            fromCard = cards[row]
        } else {
            toCard = cards[row]
        }
    }
}

