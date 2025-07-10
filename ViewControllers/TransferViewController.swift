//
//  TransferViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 10.07.2025..
//

import UIKit

class TransferViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private let cards = DatabaseManager.shared.getUserCards()
    private var selectedCard: BankCard?

    private let cardPicker = UIPickerView()
    private let balanceLabel = UILabel()
    private let ibanField = UITextField()
    private let amountField = UITextField()
    private let descriptionField = UITextField()
    private let sendButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vlastiti prijenos"
        view.backgroundColor = .systemBackground

        setupUI()

        cardPicker.dataSource = self
        cardPicker.delegate = self

        selectedCard = cards.first
        updateBalance()
    }

    private func setupUI() {
        ibanField.placeholder = "IBAN primatelja"
        amountField.placeholder = "Iznos (€)"
        descriptionField.placeholder = "Opis transakcije"

        [ibanField, amountField, descriptionField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        cardPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardPicker)

        balanceLabel.font = .systemFont(ofSize: 16)
        balanceLabel.textColor = .secondaryLabel
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(balanceLabel)

        sendButton.setTitle("Pošalji", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 10
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        view.addSubview(sendButton)

        NSLayoutConstraint.activate([
            cardPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardPicker.heightAnchor.constraint(equalToConstant: 100),

            balanceLabel.topAnchor.constraint(equalTo: cardPicker.bottomAnchor, constant: 10),
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            ibanField.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 30),
            ibanField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            ibanField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            amountField.topAnchor.constraint(equalTo: ibanField.bottomAnchor, constant: 20),
            amountField.leadingAnchor.constraint(equalTo: ibanField.leadingAnchor),
            amountField.trailingAnchor.constraint(equalTo: ibanField.trailingAnchor),

            descriptionField.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 20),
            descriptionField.leadingAnchor.constraint(equalTo: ibanField.leadingAnchor),
            descriptionField.trailingAnchor.constraint(equalTo: ibanField.trailingAnchor),

            sendButton.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 40),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 200),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateBalance() {
        if let card = selectedCard {
            balanceLabel.text = "Stanje: \(String(format: "%.2f", card.balance))€"
        }
    }

    @objc private func sendTapped() {
        guard let fromCard = selectedCard,
              let toIban = ibanField.text, toIban.count == 21,
              let amountText = amountField.text, let amount = Double(amountText), amount > 0,
              let description = descriptionField.text, !description.isEmpty else {
            showAlert("Molimo ispunite sva polja ispravno.")
            return
        }

        guard fromCard.iban != toIban else {
            showAlert("Ne možete poslati novac samome sebi.")
            return
        }

        guard amount <= fromCard.balance else {
            showAlert("Transakcija je prevelika. Provjerite stanje kartice.")
            return
        }

        let allCards = DatabaseManager.shared.getUserCards()
        guard let toCard = allCards.first(where: { $0.iban == toIban }) else {
            showAlert("Primateljev IBAN nije pronađen.")
            return
        }

        let now = Date()

        let outgoingTx = Transaction(
            id: 0,
            title: "↑↑↑ \(description)",
            amount: -amount,
            date: now,
            cardIban: fromCard.iban
        )
        DatabaseManager.shared.addTransaction(outgoingTx)

        let incomingTx = Transaction(
            id: 0,
            title: "↓↓↓ \(description)",
            amount: amount,
            date: now,
            cardIban: toCard.iban
        )
        DatabaseManager.shared.addTransaction(incomingTx)

        DatabaseManager.shared.updateBalance(for: fromCard.iban, newBalance: fromCard.balance - amount)
        DatabaseManager.shared.updateBalance(for: toCard.iban, newBalance: toCard.balance + amount)

        showAlert("Transakcija uspješna!") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(_ message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default) { _ in onDismiss?() })
        present(alert, animated: true)
    }

    // MARK: - UIPickerView DataSource & Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cards.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cards[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCard = cards[row]
        updateBalance()
    }
}

