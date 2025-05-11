//
//  PinIndicatorView.swift
//  MBankApp
//
//  Created by Ivan Posavac on 06.05.2025..
//

import UIKit

class PinIndicatorView: UIView {

    private var dots: [UIView] = []

    var totalDots: Int = 4 {
        didSet {
            setupDots()
        }
    }

    var filledCount: Int = 0 {
        didSet {
            updateDots()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDots()
    }

    private func setupDots() {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        for _ in 0..<totalDots {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = .clear
            dot.layer.borderColor = UIColor.label.cgColor
            dot.layer.borderWidth = 1.5
            dot.layer.cornerRadius = 10
            dot.widthAnchor.constraint(equalToConstant: 20).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 20).isActive = true
            dots.append(dot)
            stack.addArrangedSubview(dot)
        }

        updateDots()
    }

    private func updateDots() {
        for (index, dot) in dots.enumerated() {
            if index < filledCount {
                dot.backgroundColor = .label
            } else {
                dot.backgroundColor = .clear
            }
        }
    }
}
