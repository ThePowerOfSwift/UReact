//
//  AVAssetImageGenerator.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 9/10/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//


import AVFoundation

public extension AVAssetImageGenerator {
    
    public func generateCGImagesAsynchronouslyForTimePoints(timePoints: [TimePoint], completionHandler: @escaping AVAssetImageGeneratorCompletionHandler) {
        
        let times = timePoints.map {timePoint in
            return NSValue(time: timePoint)
        }
        self.generateCGImagesAsynchronously(forTimes: times, completionHandler: completionHandler)
    }
}
