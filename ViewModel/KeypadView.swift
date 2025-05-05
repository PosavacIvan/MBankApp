//
//  KeypadView.swift
//  MBankApp
//
//  Created by Ivan Posavac on 05.05.2025..
//

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
        mainStack.spacing = 12
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
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually

            for key in row {
                let button = UIButton(type: .system)
                button.layer.cornerRadius = 30
                button.backgroundColor = .systemGray6
                button.tintColor = .label
                button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalToConstant: 60).isActive = true

                switch key {
                case .number(let value):
                    button.setTitle(value, for: .normal)
                case .delete:
                    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
                    let icon = UIImage(systemName: "delete.left", withConfiguration: config)
                    button.setImage(icon, for: .normal)
                case .biometric:
                    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
                    let icon = UIImage(systemName: "faceid", withConfiguration: config)
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
