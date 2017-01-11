//
//  CGImageExtension.swift
//  UReact
//
//  Created by Sean Allen on 1/10/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

extension CGImage {
    
    func maskImage(image: CGImage, mask: CGImage) -> CGImage {
        
        let imageMask = CGImage(maskWidth: mask.width, height: mask.height, bitsPerComponent: mask.bitsPerComponent, bitsPerPixel: mask.bitsPerPixel, bytesPerRow: mask.bytesPerRow, provider: mask.dataProvider!, decode: nil, shouldInterpolate: true)
        
        let maskedImage = image.masking(imageMask!)
        
        return maskedImage!
    }
    
    func crop() {
        
        let croppedWidth = 215
        let croppedHeight = 215
        let centerX = (width/2) - (croppedWidth/2)
        let centerY = (height/2) - (croppedHeight/2)
        
        let croppedImage = cropping(to: CGRect(x: centerX, y: centerY, width: croppedWidth, height: croppedHeight))
    }
}
