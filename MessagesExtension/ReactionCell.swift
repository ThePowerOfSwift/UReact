//
//  ReactionCell.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/20/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import UIKit
import Messages

class ReactionCell: UICollectionViewCell {
    
    @IBOutlet weak var reactionView: MSStickerView!
    @IBOutlet weak var deleteImage: UIImageView!
    
    override func awakeFromNib() {
        layoutIfNeeded()
        deleteImage.layer.cornerRadius = deleteImage.frame.height/2
        addObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ReactionCell.showDeletionUI), name:NSNotification.Name(rawValue: Keys.showRedXs), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReactionCell.hideDeletionUI), name:NSNotification.Name(rawValue: Keys.hideRedXs), object: nil)
    }
    
    @objc func showDeletionUI() {
        deleteImage.alpha = 1.0
        reactionView.isUserInteractionEnabled = false
    }
    
    @objc func hideDeletionUI() {
        deleteImage.alpha = 0.0
        reactionView.isUserInteractionEnabled = true
    }
}
