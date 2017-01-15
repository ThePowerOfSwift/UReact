//
//  Constants.swift
//  UReact
//
//  Created by Sean Allen on 12/16/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import Foundation
import UIKit


struct Colors {
    static let peach        = UIColor(red: 250.0/255.0, green: 136.0/255.0, blue: 118.0/255.0, alpha: 1.0)
    static let darkGrey     = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    static let lightGrey    = UIColor(red: 207.0/255.0, green: 207.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    static let white        = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let black        = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
}


struct Keys {
    static let gifURLArray          = "gifURLArray"
    static let fileURLCounter       = "fileURLCounter"
    static let createReaction       = "createReaction"
    static let keepReaction         = "keepReaction"
    static let showRedXs            = "showRedX"
    static let hideRedXs            = "hideRedX"
    static let showBackArrow        = "showBackArrow"
    static let showDeleteButton     = "showDeleteButton"
    static let disableAddButton     = "disableAddButton"
    static let enableAddButton      = "enableAddButton"
}


struct StoryboardIDs {
    static let camera               = "CameraScreen"
    static let reactions            = "ReactionsPickerViewController"
}


struct Cells {
    static let reaction             = "ReactionCell"
    static let addReaction          = "AddReactionCell"
    static let removeReaction       = "RemoveReactionCell"
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
    // Add iPad Pro 12inch, and iPad Mini
}
