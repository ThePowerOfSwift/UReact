//
//  UIViewExtension.swift
//  UReact
//
//  Created by Sean Allen on 1/13/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setShadow() {
        layer.shadowColor = Colors.black.cgColor
        layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.35
        clipsToBounds = true
        layer.masksToBounds = false
    }
    
    func setPreviewShadow() {
        layer.shadowColor = Colors.uReactRed.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 50
        layer.shadowOpacity = 0.8
        clipsToBounds = true
        layer.masksToBounds = false
    }
    
    func setGradientBackground(top: UIColor, bottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        let colorTop = top.cgColor as CGColor
        let colorBottom = bottom.cgColor as CGColor
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
