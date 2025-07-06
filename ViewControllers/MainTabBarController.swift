//
//  MainTabBarController.swift
//  MBankApp
//
//  Created by Ivan Posavac on 11.05.2025..
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Cards", image: UIImage(systemName: "creditcard"), tag: 0)

        let actionVC = UIViewController()
        actionVC.tabBarItem = UITabBarItem()

        let settingsVC = UIViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)


        viewControllers = [
            UINavigationController(rootViewController: homeVC),
            actionVC,
            settingsVC
        ]

        tabBar.tintColor = .systemBlue

        // ➕ Plus Button
        let plusButton = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .bold)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        plusButton.tintColor = .systemBlue
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(plusButton)

        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            plusButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0)
        ])

        plusButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }

            let sheet = ActionSheetView()
            sheet.translatesAutoresizingMaskIntoConstraints = false

            sheet.onOptionSelected = { [weak self] option in
                guard let self = self else { return }
                sheet.removeFromSuperview()

                switch option {
                case "addCard":
                    let addVC = AddCardViewController()
                    self.presentInCurrentNavController(addVC)
                case "transfer":
                    let transferVC = TransferViewController()
                    self.presentInCurrentNavController(transferVC)

                case "payment":
                    let paymentVC = NewPaymentViewController()
                    self.presentInCurrentNavController(paymentVC)

                case "cancel":
                    break

                default:
                    break
                }
            }

            self.view.addSubview(sheet)

            NSLayoutConstraint.activate([
                sheet.topAnchor.constraint(equalTo: self.view.topAnchor),
                sheet.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                sheet.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                sheet.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])

            sheet.transform = CGAffineTransform(translationX: 0, y: 300)
            sheet.alpha = 0
            UIView.animate(withDuration: 0.3) {
                sheet.transform = .identity
                sheet.alpha = 1
            }
        }), for: .touchUpInside)
    }

    private func presentInCurrentNavController(_ viewController: UIViewController) {
        if let nav = self.selectedViewController as? UINavigationController {
            nav.pushViewController(viewController, animated: true)
        }
    }
}

