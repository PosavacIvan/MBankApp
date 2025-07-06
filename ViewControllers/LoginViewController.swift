//
//  LoginViewController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 05.05.2025..
//

import UIKit
import LocalAuthentication

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

            // 🔁 Novi layout za Keypad
            keypad.topAnchor.constraint(equalTo: pinIndicatorView.bottomAnchor, constant: 40),
            keypad.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            keypad.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            keypad.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -40),

            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
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
                self.handleBiometricLogin()
            }
        }

        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    }

    @objc private func handleLogin() {
        guard let user = DatabaseManager.shared.login(with: enteredPIN) else {
            print("❌ Pogrešan PIN")
            pinIndicatorView.shake()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            showAlert(message: "PIN nije točan.") {
                self.enteredPIN = ""
            }
            return
        }

        UserDefaults.standard.set(user.id, forKey: "loggedInUserId")

        let tabBarVC = MainTabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        self.view.window?.rootViewController = tabBarVC
        self.view.window?.makeKeyAndVisible()
    }

    private func showAlert(message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Greška", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default) { _ in
            onDismiss?()
        })
        present(alert, animated: true)
    }
    
    @objc private func handleBiometricLogin() {
        let context = LAContext()
        var error: NSError?

        // 1. Provjeri ima li uređaj biometriju
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showAlert(message: "Biometrija nije dostupna: \(error?.localizedDescription ?? "Nepoznata greška")")
            return
        }

        let reason = "Prijavite se pomoću Face ID-a"

        // 2. Autentikacija na glavnom threadu
        DispatchQueue.main.async {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Biometrija uspješna")

                        // 3. Provjeri da postoji korisnik
                        guard let userId = UserDefaults.standard.value(forKey: "loggedInUserId") as? Int64 else {
                            print("❌ Nema spremljenog korisnika — traži PIN")
                            self.showAlert(message: "Molimo prijavite se pomoću PIN-a.")
                            return
                        }

                        print("🔐 Logiran korisnik ID: \(userId)")

                        // 4. Sigurno postavi rootViewController
                        let tabBarVC = MainTabBarController()
                        tabBarVC.modalPresentationStyle = .fullScreen

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = tabBarVC
                            window.makeKeyAndVisible()
                        } else {
                            self.present(tabBarVC, animated: true)
                        }
                    } else {
                        print("❌ Biometrija nije uspjela: \(authError?.localizedDescription ?? "Nepoznata greška")")
                        // Ostani na PIN ekranu
                    }
                }
            }
        }
    }

}
