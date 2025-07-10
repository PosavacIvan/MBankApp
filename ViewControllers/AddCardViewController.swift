//
//  AddCardViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 06.07.2025..
//

import UIKit

class AddCardViewController: UIViewController {

    private let nameField = UITextField()
    private let ibanField = UITextField()
    private let colorSelector = UISegmentedControl(items: ["Plava", "Siva", "Crna"])
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dodaj karticu"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        nameField.placeholder = "Naziv kartice"
        ibanField.placeholder = "IBAN (21 znak)"
        [nameField, ibanField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        colorSelector.selectedSegmentIndex = 0
        colorSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorSelector)

        saveButton.setTitle("Spremi karticu", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            ibanField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            ibanField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            ibanField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            colorSelector.topAnchor.constraint(equalTo: ibanField.bottomAnchor, constant: 30),
            colorSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorSelector.widthAnchor.constraint(equalToConstant: 250),

            saveButton.topAnchor.constraint(equalTo: colorSelector.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func saveTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let iban = ibanField.text, iban.count == 21 else {
            showAlert(message: "Unesite ispravan naziv i IBAN (21 znak).")
            return
        }

        let selectedColor: String
        switch colorSelector.selectedSegmentIndex {
        case 0: selectedColor = "blue"
        case 1: selectedColor = "gray"
        case 2: selectedColor = "black"
        default: selectedColor = "gray"
        }

        let newCard = BankCard(
            name: name,
            iban: iban,
            balance: 2000.0, // ✅ hardkodirani početni iznos
            color: selectedColor
        )

        do {
            try DatabaseManager.shared.insertCard(newCard)
            self.navigationController?.popViewController(animated: true)
        } catch {
            showAlert(message: "Greška pri spremanju kartice.")
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Greška", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default))
        present(alert, animated: true)
    }
}
