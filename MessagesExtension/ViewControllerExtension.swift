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
    
    func createTransparencyView() -> UIView {
        let blackTransparency = UIView(frame: UIScreen.main.bounds)
        
        blackTransparency.backgroundColor = Colors.black
        blackTransparency.alpha = 0.0
        view.addSubview(blackTransparency)
        view.bringSubview(toFront: blackTransparency)
        
        return blackTransparency
    }
}
