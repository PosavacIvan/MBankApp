import UIKit

class SettingsViewController: UIViewController {

    // MARK: - UI Elements

    private let pinOptionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let pinOptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Promijeni PIN"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pinOptionArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let oldPinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Trenutni PIN"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let newPinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Novi PIN"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let confirmPinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Potvrdi novi PIN"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let savePinButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Spremi PIN", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var pinSectionVisible = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Postavke"

        setupLayout()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePinSection))
        pinOptionView.addGestureRecognizer(tapGesture)
        pinOptionView.isUserInteractionEnabled = true

        savePinButton.addTarget(self, action: #selector(handleChangePin), for: .touchUpInside)

        togglePinFields(false)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(pinOptionView)
        pinOptionView.addSubview(pinOptionLabel)
        pinOptionView.addSubview(pinOptionArrow)

        view.addSubview(oldPinTextField)
        view.addSubview(newPinTextField)
        view.addSubview(confirmPinTextField)
        view.addSubview(savePinButton)

        NSLayoutConstraint.activate([
            pinOptionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            pinOptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            pinOptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            pinOptionView.heightAnchor.constraint(equalToConstant: 50),

            pinOptionLabel.centerYAnchor.constraint(equalTo: pinOptionView.centerYAnchor),
            pinOptionLabel.leadingAnchor.constraint(equalTo: pinOptionView.leadingAnchor, constant: 16),

            pinOptionArrow.centerYAnchor.constraint(equalTo: pinOptionView.centerYAnchor),
            pinOptionArrow.trailingAnchor.constraint(equalTo: pinOptionView.trailingAnchor, constant: -16),

            oldPinTextField.topAnchor.constraint(equalTo: pinOptionView.bottomAnchor, constant: 12),
            oldPinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            oldPinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            newPinTextField.topAnchor.constraint(equalTo: oldPinTextField.bottomAnchor, constant: 12),
            newPinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            newPinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            confirmPinTextField.topAnchor.constraint(equalTo: newPinTextField.bottomAnchor, constant: 12),
            confirmPinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            confirmPinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            savePinButton.topAnchor.constraint(equalTo: confirmPinTextField.bottomAnchor, constant: 16),
            savePinButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            savePinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            savePinButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func togglePinFields(_ show: Bool) {
        oldPinTextField.isHidden = !show
        newPinTextField.isHidden = !show
        confirmPinTextField.isHidden = !show
        savePinButton.isHidden = !show
    }

    // MARK: - Actions

    @objc private func togglePinSection() {
        pinSectionVisible.toggle()
        togglePinFields(pinSectionVisible)

        UIView.animate(withDuration: 0.25) {
            self.pinOptionArrow.transform = self.pinSectionVisible ? CGAffineTransform(rotationAngle: .pi / 2) : .identity
        }
    }

    @objc private func handleChangePin() {
        guard
            let oldPin = oldPinTextField.text, !oldPin.isEmpty,
            let newPin = newPinTextField.text, !newPin.isEmpty,
            let confirmPin = confirmPinTextField.text, !confirmPin.isEmpty
        else {
            showAlert("Sva PIN polja moraju biti popunjena.")
            return
        }

        guard newPin == confirmPin else {
            showAlert("Novi PIN i potvrda se ne podudaraju.")
            return
        }

        guard let _ = DatabaseManager.shared.login(with: oldPin) else {
            showAlert("Trenutni PIN nije ispravan.")
            return
        }

        DatabaseManager.shared.updateUserPin(newPin: newPin)
        showAlert("PIN je uspješno promijenjen.")
        oldPinTextField.text = ""
        newPinTextField.text = ""
        confirmPinTextField.text = ""
        togglePinSection()
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "U redu", style: .default))
        present(alert, animated: true)
    }
}

