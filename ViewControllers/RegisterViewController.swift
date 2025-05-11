//
//  RegisterViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 06.05.2025..
//

import UIKit

class RegisterViewController: UIViewController {

    private let imeTextField = UITextField()
    private let prezimeTextField = UITextField()
    private let adresaTextField = UITextField()
    private let pinTextField = UITextField()
    private let potvrdiPinTextField = UITextField()
    private let registerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Registracija"
        setupUI()
        setupTargets()
        updateButtonState()
    }

    private func setupUI() {
        [imeTextField, prezimeTextField, adresaTextField, pinTextField, potvrdiPinTextField, registerButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        imeTextField.placeholder = "Ime"
        prezimeTextField.placeholder = "Prezime"
        adresaTextField.placeholder = "Adresa stanovanja"
        pinTextField.placeholder = "PIN (4 broja)"
        potvrdiPinTextField.placeholder = "Potvrdi PIN"
        pinTextField.keyboardType = .numberPad
        potvrdiPinTextField.keyboardType = .numberPad
        pinTextField.isSecureTextEntry = true
        potvrdiPinTextField.isSecureTextEntry = true

        [imeTextField, prezimeTextField, adresaTextField, pinTextField, potvrdiPinTextField].forEach {
            $0.borderStyle = .roundedRect
        }

        registerButton.setTitle("Registriraj se", for: .normal)
        registerButton.layer.cornerRadius = 8
        registerButton.isEnabled = false
        registerButton.backgroundColor = .systemGray3
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            imeTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            imeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            imeTextField.heightAnchor.constraint(equalToConstant: 44),

            prezimeTextField.topAnchor.constraint(equalTo: imeTextField.bottomAnchor, constant: 16),
            prezimeTextField.leadingAnchor.constraint(equalTo: imeTextField.leadingAnchor),
            prezimeTextField.trailingAnchor.constraint(equalTo: imeTextField.trailingAnchor),
            prezimeTextField.heightAnchor.constraint(equalToConstant: 44),

            adresaTextField.topAnchor.constraint(equalTo: prezimeTextField.bottomAnchor, constant: 16),
            adresaTextField.leadingAnchor.constraint(equalTo: imeTextField.leadingAnchor),
            adresaTextField.trailingAnchor.constraint(equalTo: imeTextField.trailingAnchor),
            adresaTextField.heightAnchor.constraint(equalToConstant: 44),

            pinTextField.topAnchor.constraint(equalTo: adresaTextField.bottomAnchor, constant: 16),
            pinTextField.leadingAnchor.constraint(equalTo: imeTextField.leadingAnchor),
            pinTextField.trailingAnchor.constraint(equalTo: imeTextField.trailingAnchor),
            pinTextField.heightAnchor.constraint(equalToConstant: 44),

            potvrdiPinTextField.topAnchor.constraint(equalTo: pinTextField.bottomAnchor, constant: 16),
            potvrdiPinTextField.leadingAnchor.constraint(equalTo: imeTextField.leadingAnchor),
            potvrdiPinTextField.trailingAnchor.constraint(equalTo: imeTextField.trailingAnchor),
            potvrdiPinTextField.heightAnchor.constraint(equalToConstant: 44),

            registerButton.topAnchor.constraint(equalTo: potvrdiPinTextField.bottomAnchor, constant: 40),
            registerButton.leadingAnchor.constraint(equalTo: imeTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: imeTextField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupTargets() {
        [imeTextField, prezimeTextField, adresaTextField, pinTextField, potvrdiPinTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        }
    }

    @objc private func textFieldsChanged() {
        updateButtonState()
    }

    private func updateButtonState() {
        let isImeValid = !(imeTextField.text?.isEmpty ?? true)
        let isPrezimeValid = !(prezimeTextField.text?.isEmpty ?? true)
        let isAdresaValid = !(adresaTextField.text?.isEmpty ?? true)
        let isPinValid = (pinTextField.text?.count == 4) && (pinTextField.text == potvrdiPinTextField.text)

        let isFormValid = isImeValid && isPrezimeValid && isAdresaValid && isPinValid

        registerButton.isEnabled = isFormValid
        registerButton.backgroundColor = isFormValid ? .systemBlue : .systemGray3
    }

    @objc private func registerTapped() {
        guard let ime = imeTextField.text, !ime.isEmpty,
              let prezime = prezimeTextField.text, !prezime.isEmpty,
              let adresa = adresaTextField.text, !adresa.isEmpty,
              let pin = pinTextField.text, pin.count == 4,
              pin == potvrdiPinTextField.text else {
            showAlert(message: "Unesite sve podatke ispravno.")
            return
        }

        let user = User(id: nil, ime: ime, prezime: prezime, adresa: adresa, pin: pin)

        do {
            try DatabaseManager.shared.insertUser(user)
            AuthStorage.isRegistered = true
            UserDefaults.standard.set(true, forKey: "didRegisterUser")
            print("✅ Korisnik spremljen u bazu")

            let loginVC = LoginViewController()
            navigationController?.setViewControllers([loginVC], animated: true)

        } catch {
            print("❌ Greška pri spremanju korisnika: \(error)")
            showAlert(message: "Spremanje nije uspjelo.")
        }

    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Greška", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default))
        present(alert, animated: true)
    }


}
