//
//  AuthStorage.swift
//  MBankApp
//
//  Created by Ivan Posavac on 06.05.2025..
//

import Foundation

struct AuthStorage {
    static var isRegistered: Bool {
        get {
            UserDefaults.standard.bool(forKey: "is_registered")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "is_registered")
        }
    }
}
