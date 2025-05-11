//
//  WelcomeViewModel.swift
//  MBankApp
//
//  Created by Ivan Posavac on 05.05.2025..
//

import UIKit

class WelcomeViewModel {

    weak var viewController: UIViewController?

    func registerTapped() {
        let registerVC = RegisterViewController()
        viewController?.navigationController?.pushViewController(registerVC, animated: true)
    }
}

