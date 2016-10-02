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
    reactionView.layer.cornerRadius = reactionView.frame.height/2
  }
  
    
}
