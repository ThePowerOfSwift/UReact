//
//  URGhostButton.swift
//  UReact
//
//  Created by Sean Allen on 2/7/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

class URGhostButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        layer.borderWidth = 2.0
        layer.borderColor = Colors.uReactRed.cgColor
    }
}
