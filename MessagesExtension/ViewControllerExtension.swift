//
//  ViewControllerExtension.swift
//  UReact
//
//  Created by Sean Allen on 12/24/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        let colorTop = Colors.darkGrey.cgColor as CGColor
        let colorBottom = Colors.lightGrey.cgColor as CGColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func createTransparencyView() -> UIView {
        let blackTransparency = UIView(frame: UIScreen.main.bounds)
        
        blackTransparency.backgroundColor = Colors.black
        blackTransparency.alpha = 0.0
        view.addSubview(blackTransparency)
        view.bringSubview(toFront: blackTransparency)
        
        return blackTransparency
    }
}
