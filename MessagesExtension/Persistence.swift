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
    static var dataArray = defaults.array(forKey: Keys.gifDataArray) as! [Data]
    
    class func createGifDataArray() {
        if defaults.array(forKey: Keys.gifDataArray) == nil {
            let storeDataArray: [Data] = []
            defaults.set(storeDataArray, forKey: Keys.gifDataArray)
        }
    }
    
    // try an update saved array funtion that combines a lot of steps
    
    
    
    
        
}
