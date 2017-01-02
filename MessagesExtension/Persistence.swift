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
   
    
    // try an update saved array funtion that combines a lot of steps
    
    
    
    
        
}
