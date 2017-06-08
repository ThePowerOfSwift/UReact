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
    
    class func rotate90Degree(_ cgImage: CGImage) -> CGImage {
        
        let width = Int(cgImage.width)
        let height = Int(cgImage.height)
        let newWidth: Int = height
        let newHeight: Int = width
        
        let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = bytesPerPixel * newWidth
        let bitsPerComponent: Int = 8
        let bitmapInfo: UInt32 = cgImage.bitmapInfo.rawValue

        let context = CGContext(data: nil, width: newWidth, height: newHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo)
        
        context?.rotate(by: -(CGFloat)(Double.pi/2))
        context?.translateBy(x: -(CGFloat)(Int(newHeight)), y: 0)
        context?.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
        
        let rotatedImage = context?.makeImage()
        
        return rotatedImage!
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
