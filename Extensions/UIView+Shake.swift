//
//  UIView+Shake.swift
//  MBankApp
//
//  Created by Ivan Posavac on 11.05.2025..
//

import UIKit

extension UIView {
    func shake(duration: CFTimeInterval = 0.4, values: [CGFloat] = [-10, 10, -8, 8, -5, 5, 0]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = duration
        animation.values = values
        layer.add(animation, forKey: "shake")
    }
}
