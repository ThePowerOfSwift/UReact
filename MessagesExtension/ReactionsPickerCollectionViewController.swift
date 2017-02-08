//
//  ReactionsPickerCollectionViewController.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/20/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import UIKit
import Messages
import ImageIO

class ReactionsPickerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: URGhostButton!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet var confirmationViews: [UIView]!
    
    var transparencyView: UIView!
    var indexPathToDelete: IndexPath?
    
    enum CollectionViewItem {
        case reactionSticker(MSSticker)
        case addReaction
        case removeReaction
    }
    
    var reactions: [CollectionViewItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Persistence.createGifPersistence()
        reactions.append(.removeReaction)
        reactions.append(.addReaction)
        transparencyView = createTransparencyView()
        view.setGradientBackground(top: Colors.lightGrey, bottom: Colors.veryDarkGrey)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGIFArray()
    }
    
    
    func createGIFArray() {
        
        let gifURLArray = Persistence.retrieveSavedURLs()
        
        if gifURLArray.count != 0 {
    
            reactions.removeAll()
            reactions.append(.removeReaction)
            reactions.append(.addReaction)
            
            for urlString in gifURLArray {
                createSticker(urlString)
            }
        }
        collectionView.reloadDataOnMainThread()
    }
    
    
    func createSticker(_ gifPath: String) {
        
        let stickerURL = URL(fileURLWithPath: gifPath)
        let sticker: MSSticker
        
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: "Reaction GIF")
            reactions.append(.reactionSticker(sticker))
        } catch {
            print("Error creating sticker = \(error)")
            return
        }
    }
    
    
    func showDeletionConfiration(bool: Bool) {
        
        self.transparencyView.alpha = bool ? 0.9 : 0.0
        
        UIView.animate(withDuration: 0.4, animations: {
            for button in self.confirmationViews {
                button.alpha = bool ? 1.0 : 0.0
                self.view.bringSubview(toFront: button)
            }
        })
    }
    
    
    @IBAction func keepButtonPressed(_ sender: UIButton) {
        showDeletionConfiration(bool: false)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: URGhostButton) {
        guard let indexPath = indexPathToDelete else { return }
        reactions.remove(at: indexPath.row)
        Persistence.removeURL(at: indexPath)
        collectionView.reloadDataOnMainThread()
        showDeletionConfiration(bool: false)
    }
}

    
extension ReactionsPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactions.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reaction = self.reactions[indexPath.row]
        
        switch reaction {
        case .reactionSticker(let reactionSticker):
            return dequeueReactionStickerCell(for: reactionSticker, at: indexPath)
            
        case .addReaction:
            return dequeueAddStickerCell(at: indexPath)
            
        case .removeReaction:
            return dequeueRemoveStickerCell(at: indexPath)
        }
    }
    
    
    fileprivate func dequeueReactionStickerCell(for reaction: MSSticker, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.reaction, for: indexPath) as! ReactionCell
        cell.reactionView.sticker = reaction
        return cell
    }
    
    
    fileprivate func dequeueAddStickerCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.addReaction, for: indexPath) as! AddReactionCell
        cell.addImage.image = #imageLiteral(resourceName: "add-button")
        return cell
    }
    
    
    fileprivate func dequeueRemoveStickerCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.removeReaction, for: indexPath) as! RemoveReactionCell
        
        let image: UIImage = isEditing ? #imageLiteral(resourceName: "back-arrow") : #imageLiteral(resourceName: "delete-button")
        cell.removeImage.image = image
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reaction = reactions[indexPath.row]

        switch reaction {
        case .addReaction:
            NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.createReaction), object: nil)
            
        case .removeReaction:
            
            isEditing = isEditing ? false : true
            
            let addReactionKey      = isEditing ? Keys.disableAddButton : Keys.enableAddButton
            let removeReactionKey   = isEditing ? Keys.showBackArrow : Keys.showDeleteButton
            let reactionKey         = isEditing ? Keys.showRedXs : Keys.hideRedXs
            
            for reaction in reactions {
                
                switch reaction {
                case .addReaction:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: addReactionKey), object: nil)
                case .removeReaction:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: removeReactionKey), object: nil)
                case .reactionSticker(_):
                    NotificationCenter.default.post(name: Notification.Name(rawValue: reactionKey), object: nil)
                }
            }
            
        case.reactionSticker(_):
            
            if isEditing {
                indexPathToDelete = indexPath
                showDeletionConfiration(bool: true)
            }
        }
    }
    
    
    fileprivate func stickerCanAnimate(_ sticker: MSSticker) -> Bool {
        guard let stickerImageSource = CGImageSourceCreateWithURL(sticker.imageFileURL as CFURL, nil) else { return false }
        let stickerImageFrameCount = CGImageSourceGetCount(stickerImageSource)
        
        return stickerImageFrameCount > 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (cell.reuseIdentifier == Cells.reaction) {
            let reactionCell = cell as! ReactionCell
            
            if stickerCanAnimate(reactionCell.reactionView.sticker!) {
                reactionCell.reactionView.startAnimating()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (cell.reuseIdentifier == Cells.reaction) {
            let reactionCell = cell as! ReactionCell
            
            if reactionCell.reactionView.isAnimating() {
                reactionCell.reactionView.stopAnimating()
            }
        }
    }
}

