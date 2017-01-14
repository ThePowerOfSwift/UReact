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
    
    enum CollectionViewItem {
        case reactionSticker(MSSticker)
        case addReaction
        case removeReaction
    }
    
    var reactions: [CollectionViewItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Persistence.createGifPersistence()
        reactions.append(.addReaction)
        reactions.append(.removeReaction)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // find out why this gets called twice when laoding the app or switching to this screen
        createGIFArray()
    }
    
    
    func createGIFArray() {
        
        let gifURLArray = Persistence.retrieveSavedURLs()
        
        if gifURLArray.count != 0 {
    
            reactions.removeAll()
            reactions.append(.addReaction)
            reactions.append(.removeReaction)
            
            for urlString in gifURLArray {
                createSticker(urlString)
                Persistence.printFileSize(url: urlString) // Temp for debugging
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
        cell.addImage.image = #imageLiteral(resourceName: "Plus-500")
        return cell
    }
    
    
    fileprivate func dequeueRemoveStickerCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.removeReaction, for: indexPath) as! RemoveReactionCell
        cell.removeImage.image = #imageLiteral(resourceName: "Oval")
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reaction = reactions[indexPath.row]
        
        switch reaction {
        case .addReaction:
            NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.createReaction), object: nil)
            print(collectionView.indexPathsForSelectedItems!)
            
        case .removeReaction:
            isEditing = isEditing ? false : true // Likely need to move this
//            setEditing(isEditing, animated: true)
            print("IsEditing = \(isEditing)")
        
            
            
            // "X" pressed - isEditing is TRUE
            // in didSelectItemAt - add contion for IF isEditing
                // If isEditing == true
                    // disable (adjust image accordingly) Add Reaction button
                    // Unhide image view of red X on the reaction cells
                    // Present pop up to delete cell at selected index path (be sure this can only be a reaction)
                    // Delete Cell if "Yes" Selected
                    // Reload collectionView on main thread
                    // Switch back arrow image back to trash
            
                    // Watch were you switch the isEditing flag back and forth. Likely the end of each case
            
                // ELSE 
                    // For .addReaction and .reactionSticker - normal functionality
                    // For .removeAction cell, switch trash button to back arrow and change isEditing to TRUE
            
    
        default:
            break
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

