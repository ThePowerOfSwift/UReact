//
//  GifImage.swift
//  UReact
//
//  Created by Sean Allen on 1/10/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

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
    
    class func rotateForLandscape(imageRef: CGImage) -> CGImage {
        
        let rotatedImage = createMatchingBackingDataWithImage(imageRef: imageRef, orientation: .right)
        
        return rotatedImage!
    }
    
    class func createMatchingBackingDataWithImage(imageRef: CGImage?, orientation: UIImageOrientation) -> CGImage? {
        
        var orientedImage: CGImage?
        
        if let imageRef = imageRef {
            
            
            print("imageRef = \(imageRef)")
            
            let originalWidth = imageRef.width
            let originalHeight = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            
            let colorSpace = imageRef.colorSpace
            let bitmapInfo = imageRef.bitmapInfo
            
            var degreesToRotate: Double
            var swapWidthHeight: Bool
            var mirrored: Bool
            
            switch orientation {
                
            case .up:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = false
                break
            case .upMirrored:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = true
                break
            case .right:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .rightMirrored:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = true
                break
            case .down:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = false
                break
            case .downMirrored:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = true
                break
            case .left:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .leftMirrored:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = true
                break
            }
            
            let radians = (degreesToRotate * .pi / 180)
            
            var width: Int
            var height: Int
            
            if swapWidthHeight {
                width = originalHeight
                height = originalWidth
            } else {
                width = originalWidth
                height = originalHeight
            }
            
            
            let contextRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
            
            contextRef!.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
            
            
            if mirrored {
                contextRef!.scaleBy(x: -1.0, y: 1.0)
            }
            contextRef!.rotate(by: CGFloat(radians))
            if swapWidthHeight {
                contextRef!.translateBy(x: -CGFloat(height) / 2.0, y: -CGFloat(width) / 2.0)
            } else {
                contextRef!.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
            }
//            CGContextDrawImage(contextRef, CGRect(0.0, 0.0, CGFloat(originalWidth), CGFloat(originalHeight)), imageRef)
            
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(originalWidth), height: CGFloat(originalHeight)))

            orientedImage = contextRef!.makeImage()
        }
        
        return orientedImage
    }
    
    class func adjustPreviewForScreenSize(width: NSLayoutConstraint, height: NSLayoutConstraint) {
        
        if DeviceTypes.iPhone5 || DeviceTypes.iPhone7Zoomed {
            width.constant = 190
            height.constant = 190
        } else if DeviceTypes.iPhone7PlusStandard {
            width.constant = 240
            height.constant = 240
        } else if DeviceTypes.iPad {
            width.constant = 460
            height.constant = 460
        }
    }
}
