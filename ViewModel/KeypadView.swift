import UIKit

enum KeypadKey {
    case number(String)
    case biometric
    case delete
}

class KeypadView: UIView {

    var onKeyPressed: ((KeypadKey) -> Void)?

    private let buttons: [[KeypadKey]] = [
        [.number("1"), .number("2"), .number("3")],
        [.number("4"), .number("5"), .number("6")],
        [.number("7"), .number("8"), .number("9")],
        [.biometric, .number("0"), .delete]
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        for row in buttons {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill

            for key in row {
                let button = UIButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.widthAnchor.constraint(equalToConstant: 70).isActive = true
                button.heightAnchor.constraint(equalToConstant: 70).isActive = true
                button.backgroundColor = .systemGray6
                button.tintColor = .label
                button.layer.cornerRadius = 35
                button.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)

                switch key {
                case .number(let value):
                    button.setTitle(value, for: .normal)
                case .delete:
                    let icon = UIImage(systemName: "delete.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
                    button.setImage(icon, for: .normal)
                case .biometric:
                    let icon = UIImage(systemName: "faceid", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
                    button.setImage(icon, for: .normal)
                }

                button.addAction(UIAction(handler: { [weak self] _ in
                    self?.onKeyPressed?(key)
                }), for: .touchUpInside)

                rowStack.addArrangedSubview(button)
            }

            mainStack.addArrangedSubview(rowStack)
        }
    }
}
