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
    
    private let pinIndicatorView: PinIndicatorView = {
        let view = PinIndicatorView()
        view.totalDots = 4
        view.filledCount = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let keypad = KeypadView()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Prijavi se u mBanking", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var enteredPIN = "" {
        didSet {
            pinIndicatorView.filledCount = enteredPIN.count
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
        view.addSubview(pinIndicatorView)
        view.addSubview(keypad)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            pinLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            pinLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pinIndicatorView.topAnchor.constraint(equalTo: pinLabel.bottomAnchor, constant: 24),
            pinIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinIndicatorView.heightAnchor.constraint(equalToConstant: 30),
            
            keypad.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keypad.topAnchor.constraint(equalTo: pinIndicatorView.bottomAnchor, constant: 40),
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
                print("🔐 Face ID tapped") // kasnije dodati autentikaciju
            }
        }
        
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    }
    
    @objc private func loginTapped() {
        do {
            if let user = try DatabaseManager.shared.fetchUser(),
               enteredPIN == user.pin {
                print("✅ PIN is correct, login success")
                let tabBar = MainTabBarController()
                navigationController?.setViewControllers([tabBar], animated: true)
            } else {
                print("❌ Pogrešan PIN")

                // 🔃 Shake animacija
                pinIndicatorView.shake()

                // 📳 Haptika
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)

                // ❗️ Alert + reset PIN-a
                showAlert(message: "PIN nije točan.") { [weak self] in
                    self?.enteredPIN = ""
                }
            }
        } catch {
            print("❌ Greška pri dohvaćanju korisnika: \(error)")
            showAlert(message: "Došlo je do greške.")
        }
    }

    private func showAlert(message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Greška", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default) { _ in
            onDismiss?()
        })
        present(alert, animated: true)
    }
    
    @objc private func handleLogin() {
        guard let user = DatabaseManager.shared.login(with: enteredPIN) else {
            print("❌ Pogrešan PIN")
            return
        }

        UserDefaults.standard.set(user.id, forKey: "loggedInUserId")

        let tabBarVC = MainTabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        self.view.window?.rootViewController = tabBarVC
        self.view.window?.makeKeyAndVisible()
    }
}
