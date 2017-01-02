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
    
    
    // Temp debugging function
    class func printFileSize(url: String) {
        
        let fileManager = FileManager.default
        var gifData: Data?
        
        let appendString = fileManager.displayName(atPath: url)
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(appendString)
        gifData = fileManager.contents(atPath: imagePath)
        print("gif Data = \(gifData!)")
        
    }
    
    class func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    
    
    
    
}
