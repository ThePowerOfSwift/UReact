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
}
