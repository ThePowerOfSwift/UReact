//
//  CameraTransparencyView.swift
//  UReact
//
//  Created by Sean Allen on 1/2/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

class CameraOverlay: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createCircleOverlay(frame: CGRect, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> UIView {
        
        let overlayView = UIView(frame: frame)
        overlayView.alpha = 1.0
        overlayView.backgroundColor = Colors.darkGrey
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    func createSquareOverlay(frame: CGRect, xOffset: CGFloat, yOffset: CGFloat, visibleWidth: CGFloat, visibleHeight: CGFloat) -> UIView {
        
        let overlayView = UIView(frame: frame)
        overlayView.alpha = 1.0
        overlayView.backgroundColor = Colors.darkGrey
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: xOffset, y: yOffset, width: visibleWidth, height: visibleHeight))
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
}
