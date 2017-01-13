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
        //        reactionView.layer.shadowColor = Colors.black.cgColor
        //        reactionView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        //        reactionView.layer.shadowRadius = 5
        //        reactionView.layer.shadowOpacity = 0.35
        //        reactionView.layer.cornerRadius = reactionView.frame.height/2
        //        reactionView.clipsToBounds = false
        //        reactionView.layer.masksToBounds = false
        
        backgroundColor = Colors.lightGrey
    }
    
}
