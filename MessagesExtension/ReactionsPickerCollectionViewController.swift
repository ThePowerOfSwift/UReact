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
    }
    
    var reactions: [CollectionViewItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = Colors.peach
        Persistence.createGifPersistence()
        reactions.append(.addReaction)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reaction = reactions[indexPath.row]
        
        switch reaction {
        case .addReaction:
            NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.createReaction), object: nil)
            
        default:
            break
        }
    }
    
    fileprivate func stickerCanAnimate(_ sticker: MSSticker) -> Bool {
        guard let stickerImageSource = CGImageSourceCreateWithURL(sticker.imageFileURL as CFURL, nil) else {
            return false
        }
        
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

