//
//  Constants.swift
//  UReact
//
//  Created by Sean Allen on 12/16/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let defaults = UserDefaults.standard
}

struct Colors {
    
    static let peach        = UIColor(red: 250.0/255.0, green: 136.0/255.0, blue: 118.0/255.0, alpha: 1.0)
    static let red          = UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    static let redAlpha     = UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 0.2)
    static let orange       = UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 71.0/255.0, alpha: 1.0)
    static let yellow       = UIColor(red: 255.0/255.0, green: 205.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    static let lightGreen   = UIColor(red: 169.0/255.0, green: 228.0/255.0, blue: 109.0/255.0, alpha: 1.0)
    static let green        = UIColor(red: 91.0/255.0, green: 197.0/255.0, blue: 159.0/255.0, alpha: 1.0)
    static let darkGreen    = UIColor(red: 37.0/255.0, green: 161.0/255.0, blue: 117.0/255.0, alpha: 1.0)
    static let blue         = UIColor(red: 96.0/255.0, green: 160.0/255.0, blue: 235.0/255.0, alpha: 1.0)
    static let darkGrey     = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    static let grey         = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    static let lightGrey    = UIColor(red: 207.0/255.0, green: 207.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    static let black        = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
}

struct Keys {
    static let gifURLArray          = "gifURLArray"
    static let fileURLCounter       = "fileURLCounter"
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceTypes {
    static let iPhone4              = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let iPhone5              = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let iPhone7Standard      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0 && UIScreen.main.nativeScale == UIScreen.main.scale
    static let iPhone7Zoomed        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0 && UIScreen.main.nativeScale > UIScreen.main.scale
    static let iPhone7PlusStandard  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let iPhone7PlusZoomed    = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0 && UIScreen.main.nativeScale < UIScreen.main.scale
    static let iPad                 = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
