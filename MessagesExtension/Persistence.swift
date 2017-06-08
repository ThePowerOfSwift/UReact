//
//  Persistence.swift
//  UReact
//
//  Created by Sean Allen on 12/31/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import Foundation

class Persistence {
    
    static let defaults = UserDefaults.standard
    static var gifURLArray = defaults.array(forKey: Keys.gifURLArray) as! [String]
    
    class func createGifPersistence() {
        
        if defaults.array(forKey: Keys.gifURLArray) == nil {
            let emptyGIFArray: [String] = []
            defaults.set(emptyGIFArray, forKey: Keys.gifURLArray)
            defaults.set(0, forKey: Keys.fileURLCounter)
        }
    }
    
    
    class func retrieveSavedURLs() -> [String] {
        
        let array: [String] = defaults.array(forKey: Keys.gifURLArray) as! [String]
        return array
    }
    
    
    class func getDirectoryPath() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    
    class func createTempFilePath() -> URL {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("temp.mp4")
        
        return filePath
    }
    
    
    class func createGifFilePath() -> URL {
        
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentsDirectoryURL.appendingPathComponent(incrementURL())
        
        return fileURL
    }
    
    
    class func incrementURL() -> String {
        
        let urlCount = Persistence.defaults.integer(forKey: Keys.fileURLCounter)
        let incrementedURLCount: Int = urlCount + 1
        let urlCountString = String(incrementedURLCount)
        let incrementedPathComponent = "reactionGif\(urlCountString).gif"
        
        Persistence.defaults.set(incrementedURLCount, forKey: Keys.fileURLCounter)
        
        return incrementedPathComponent
    }
    
    
    class func persistURL(url: String) {
        
        var gifURLArray: [String] = Persistence.defaults.array(forKey: Keys.gifURLArray) as! [String]
        gifURLArray.append(url)
        Persistence.defaults.set(gifURLArray, forKey: Keys.gifURLArray)
        // Need to handle error if URL not generated from .createGIF() in Camera Screen
    }
    
    class func removeURL(at: IndexPath) {
        
        var gifURLArray: [String] = Persistence.defaults.array(forKey: Keys.gifURLArray) as! [String]
        gifURLArray.remove(at: at.row - 2)
        Persistence.defaults.set(gifURLArray, forKey: Keys.gifURLArray)
        // Need to handle error if URL not generated from .createGIF() in Camera Screen
    }
}
