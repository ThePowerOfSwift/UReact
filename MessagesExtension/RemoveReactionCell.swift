//
//  RemoveReactionCell.swift
//  UReact
//
//  Created by Sean Allen on 1/12/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import UIKit

class RemoveReactionCell: UICollectionViewCell {
    
    @IBOutlet weak var removeImage: UIImageView!
    
    
    override func awakeFromNib() {
        layoutIfNeeded()
        addObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(RemoveReactionCell.showDeletionUI), name:NSNotification.Name(rawValue: Keys.showBackArrow), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RemoveReactionCell.hideDeletionUI), name:NSNotification.Name(rawValue: Keys.showDeleteButton), object: nil)
    }
    
    func showDeletionUI() {
        removeImage.image = #imageLiteral(resourceName: "red-x")
    }
    
    func hideDeletionUI() {
        removeImage.image = #imageLiteral(resourceName: "Oval")
    }
}
