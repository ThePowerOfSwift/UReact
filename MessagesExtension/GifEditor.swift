//
//  GifImage.swift
//  UReact
//
//  Created by Sean Allen on 1/10/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

class GifEditor: NSObject {
    
    
    class func crop(imageRef: CGImage) -> CGImage {
        
        let croppedWidth = 215
        let croppedHeight = 215
        let centerX = (imageRef.width/2) - (croppedWidth/2)
        let centerY = (imageRef.height/2) - (croppedHeight/2)
        
        let croppedImage = imageRef.cropping(to: CGRect(x: centerX, y: centerY, width: croppedWidth, height: croppedHeight))
        
        return croppedImage!
    }
    
    class func mask(image: CGImage, mask: CGImage) -> CGImage {
        
        let imageMask = CGImage(maskWidth: mask.width, height: mask.height, bitsPerComponent: mask.bitsPerComponent, bitsPerPixel: mask.bitsPerPixel, bytesPerRow: mask.bytesPerRow, provider: mask.dataProvider!, decode: nil, shouldInterpolate: true)
        
        let maskedImage = image.masking(imageMask!)
        
        return maskedImage!
    }
}
