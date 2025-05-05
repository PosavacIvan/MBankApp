//
//  LoginViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 05.05.2025..
//

import UIKit

class LoginViewController: UIViewController {

    private let pinLabel: UILabel = {
        let label = UILabel()
        label.text = "Unesite svoj PIN"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pinDisplayLabel: UILabel = {
        let label = UILabel()
        label.text = "●●●●"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let keypad = KeypadView()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Prijavi se u mBanking", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var enteredPIN = "" {
        didSet {
            let bullets = String(repeating: "●", count: enteredPIN.count)
            let padded = bullets.padding(toLength: 4, withPad: "○", startingAt: 0)
            pinDisplayLabel.text = padded
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        view.addSubview(pinLabel)
        view.addSubview(pinDisplayLabel)
        view.addSubview(keypad)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            pinLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            pinLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            pinDisplayLabel.topAnchor.constraint(equalTo: pinLabel.bottomAnchor, constant: 16),
            pinDisplayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            keypad.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keypad.topAnchor.constraint(equalTo: pinDisplayLabel.bottomAnchor, constant: 40),
            keypad.widthAnchor.constraint(equalToConstant: 260),
            keypad.heightAnchor.constraint(equalToConstant: 360),

            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupActions() {
        keypad.onKeyPressed = { [weak self] key in
            guard let self = self else { return }
            switch key {
            case .number(let value):
                if self.enteredPIN.count < 4 {
                    self.enteredPIN.append(value)
                }
            case .delete:
                if !self.enteredPIN.isEmpty {
                    self.enteredPIN.removeLast()
                }
            case .biometric:
                print("🔐 Face ID tapped") // dodaj FaceID autentikaciju kasnije
            }
        }

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    @objc private func loginTapped() {
        if enteredPIN == "1234" {
            print("✅ PIN is correct, login success")
        } else {
            print("❌ Pogrešan PIN")
        }
    }
}
