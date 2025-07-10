//
//  PaymentViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 10.07.2025..
//

import UIKit

class PaymentViewController: UIViewController {

    private let cards = DatabaseManager.shared.getUserCards()
    private var selectedCard: BankCard?

    private let cardPicker = UIPickerView()
    private let ibanField = UITextField()
    private let amountField = UITextField()
    private let descriptionField = UITextField()
    private let sendButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Novo plaćanje"
        view.backgroundColor = .systemBackground

        selectedCard = cards.first

        cardPicker.delegate = self
        cardPicker.dataSource = self

        setupUI()
    }

    private func setupUI() {
        ibanField.placeholder = "IBAN primatelja"
        ibanField.borderStyle = .roundedRect
        ibanField.autocapitalizationType = .allCharacters

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

        let stack = UIStackView(arrangedSubviews: [cardPicker, ibanField, amountField, descriptionField, sendButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func sendTapped() {
        guard let fromCard = selectedCard,
              let toIban = ibanField.text, toIban.count >= 10,
              let amountText = amountField.text, let amount = Double(amountText), amount > 0,
              let description = descriptionField.text, !description.isEmpty else {
            showAlert("Molimo ispunite sva polja ispravno.")
            return
        }

        guard toIban != fromCard.iban else {
            showAlert("Ne možete poslati novac samome sebi.")
            return
        }

        guard amount <= fromCard.balance else {
            showAlert("Transakcija je prevelika. Provjerite stanje kartice.")
            return
        }

        let now = Date()

        // Transakcija za pošiljatelja
        let outgoingTx = Transaction(
            id: 0,
            title: "↑↑↑ \(description)",
            amount: -amount,
            date: now,
            cardIban: fromCard.iban
        )
        DatabaseManager.shared.addTransaction(outgoingTx)
        DatabaseManager.shared.updateBalance(for: fromCard.iban, newBalance: fromCard.balance - amount)

        // Ako je primatelj također korisnik ove aplikacije, dodaj i dolaznu transakciju
        if let toCard = cards.first(where: { $0.iban == toIban }) {
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

        showAlert("Transakcija uspješna!") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(_ message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default) { _ in onDismiss?() })
        present(alert, animated: true)
    }
}

extension PaymentViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cards.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cards[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCard = cards[row]
    }
}
