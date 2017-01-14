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
        layer.shadowOffset = CGSize(width: 8.0, height: 8.0)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.35
        clipsToBounds = false
        layer.masksToBounds = false
        
    }
}
