//
//  AddReactionCell.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/20/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import UIKit

class AddReactionCell: UICollectionViewCell {
    
    @IBOutlet weak var addImage: UIImageView!
    
    override func awakeFromNib() {
        layoutIfNeeded()
        addObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(AddReactionCell.showDeletionUI), name:NSNotification.Name(rawValue: Keys.disableAddButton), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddReactionCell.hideDeletionUI), name:NSNotification.Name(rawValue: Keys.enableAddButton), object: nil)
    }
    
    func showDeletionUI() {
        addImage.alpha = 0.25
        isUserInteractionEnabled = false
    }
    
    func hideDeletionUI() {
        addImage.alpha = 1.0
        isUserInteractionEnabled = true
    }
    
}
