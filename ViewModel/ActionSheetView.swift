//
//  ActionSheetView.swift
//  MBankApp
//
//  Created by Ivan Posavac on 11.05.2025..
//

import UIKit

class ActionSheetView: UIView {

    var onOptionSelected: ((String) -> Void)?

    private let stack = UIStackView()
    private let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyCardRules()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        // Blur background
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffect)
        NSLayoutConstraint.activate([
            blurEffect.topAnchor.constraint(equalTo: topAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Wrapper za sadržaj koji ide pri dnu
        let contentWrapper = UIView()
        contentWrapper.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentWrapper)

        NSLayoutConstraint.activate([
            contentWrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentWrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentWrapper.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // Stack s gumbima
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentWrapper.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentWrapper.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentWrapper.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentWrapper.trailingAnchor, constant: -24)
        ])

        // Dodaj kartice
        stack.addArrangedSubview(createCard(title: "Dodaj karticu", icon: "plus.circle", key: "addCard"))
        stack.addArrangedSubview(createCard(title: "Vlastiti prijenos", icon: "arrow.left.arrow.right", key: "transfer"))
        stack.addArrangedSubview(createCard(title: "Novo plaćanje", icon: "creditcard", key: "payment"))

        // X gumb ispod stacka
        contentWrapper.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 32),
            closeButton.centerXAnchor.constraint(equalTo: contentWrapper.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor)
        ])
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }


    private func createCard(title: String, icon: String, key: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 6
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView(arrangedSubviews: [iconView, label])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        container.addGestureRecognizer(tap)
        container.accessibilityLabel = key

        return container
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let key = view.accessibilityLabel else { return }
        onOptionSelected?(key)
    }

    @objc private func closeTapped() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 300)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    private func applyCardRules() {
        let cards = DatabaseManager.shared.getUserCards()
        let count = cards.count

        for view in stack.arrangedSubviews {
            guard let label = (view.subviews.first as? UIStackView)?.arrangedSubviews.last as? UILabel else { continue }

            if label.text == "Dodaj karticu" {
                view.isUserInteractionEnabled = true
                view.alpha = 1.0
            }
            else if label.text == "Vlastiti prijenos" {
                view.isUserInteractionEnabled = count >= 2
                view.alpha = count >= 2 ? 1.0 : 0.4
            }
            else if label.text == "Novo plaćanje" {
                view.isUserInteractionEnabled = count >= 1
                view.alpha = count >= 1 ? 1.0 : 0.4
            }
        }
    }
}
