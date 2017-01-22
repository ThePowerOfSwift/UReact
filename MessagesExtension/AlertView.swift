//
//  AlertView.swift
//  UReact
//
//  Created by Sean Allen on 1/18/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

class AlertView {
    
    
    // Use a Notification for when Delete is pressed.
    
    class func deleteReaction() -> UIAlertController {
        
        let alertController = UIAlertController(title: "Delete Reaction", message: "Are you sure you want to permanently delete this reaction?", preferredStyle: .alert)
        let DestructiveAction = UIAlertAction(title: "Bye, Felicia", style: .destructive) {
            (result : UIAlertAction) -> Void in
            print("This is where we would delete the reacion and reload")
//            NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.deleteReaction), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.deleteReaction), object: IndexPath.self)
        }
        
        let okAction = UIAlertAction(title: "Keep it", style: .default) {
            (result : UIAlertAction) -> Void in
            print("Keep Reaction")
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        
        return alertController
    }
}
