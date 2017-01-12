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
    
    override func awakeFromNib() {
        layoutIfNeeded()
        reactionView.layer.shadowColor = Colors.black.cgColor
        reactionView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        reactionView.layer.shadowRadius = 5
        reactionView.layer.shadowOpacity = 0.35
        reactionView.layer.cornerRadius = reactionView.frame.height/2
        reactionView.clipsToBounds = false
        reactionView.layer.masksToBounds = false
        
        backgroundColor = Colors.lightGrey
    }
}
