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


class ReactionsPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var testGIFView: UIImageView!
    
    enum CollectionViewItem {
        case reactionSticker(MSSticker)
        case addReaction
    }
    
    var reactions: [CollectionViewItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reactions = [CollectionViewItem]()
        reactions.append(.addReaction)
        
        collectionView.backgroundColor = Colors.peach
        Persistence.createGifPersistence()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewWillAppear gets called when switching to .compact presentation style
        createGIFArray()
    }
    
    //Pull in GIFs from Document Directory
    func createGIFArray() {
        
        let fileManager = FileManager.default
        
        var gifData: Data?
        
        // Pull up saved array
        let gifURLArray: [String] = Persistence.defaults.array(forKey: Keys.gifURLArray) as! [String]
        print("gifURLArray count = \(gifURLArray.count)")
        
        //Iterarate through array and create sticker
        if gifURLArray.count != 0 {
    
            reactions.removeAll()
            reactions.append(.addReaction)
            
            // Iterate through array and create GIFs from URLs
            for urlString in gifURLArray {
                
                let appendString = fileManager.displayName(atPath: urlString)
                print("AppendedString = \(appendString)")
                
                let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(appendString)
                print("imagePat = \(imagePath)")
                
                
                gifData = fileManager.contents(atPath: imagePath)
                print("gif Data = \(gifData!)")
                
                createSticker(urlString)
            }
            
            // 
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        
//        
//        
//        
//        
//        // Handle if nothing exists in FilePath (either new user or deletion)
//        
//        
//        let fileManager = FileManager.default
//        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("reactionGif4.gif")
//        print("imagePath = \(imagePath)")
//        
//        //convert string to URL for gif creation
//        let gifURL = URL(string: imagePath)
//        print("gifURL = \(gifURL)")
//        
//        
//        if fileManager.fileExists(atPath: imagePath){
//            
////            do {
////                gifData = try Data(contentsOf: gifURL!)
////            } catch {
////                print("No URL found at document picked")
////            }
//            
//            gifData = fileManager.contents(atPath: imagePath)
//            
//            
//            DispatchQueue.main.async {
//                self.testGIFView.layoutIfNeeded()
//                let gif = UIImage.gif(data: gifData!)!
//                self.testGIFView.image = gif
//            }
//            
//        }else{
//            print("No Image")
//        }
        
    }
    

    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func createSticker(_ gifPath: String) {
        
        let stickerURL = URL(fileURLWithPath: gifPath)
        
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: "Reaction GIF")
            reactions.append(.reactionSticker(sticker))
            print("Sticker created - \(sticker.debugDescription)")
        } catch {
            print("Error creating sticker = \(error)")
            return
        }
    }
    
    //GIF Version
//    func createSticker(_ assetName: String, localizedDescription: String) {
//        
//        guard let stickerPath = Bundle.main.path(forResource: assetName, ofType: "gif") else {
//            print("Could not create sticker path for \(assetName)")
//            return
//        }
//        
//        let stickerURL = URL(fileURLWithPath: stickerPath)
//        
//        let sticker: MSSticker
//        do {
//            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
//            reactions.append(.reactionSticker(sticker))
//        } catch {
//            print(error)
//            return
//        }
//    }
    
    
    // MARK: UICollectionViewDataSource
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReactionCell", for: indexPath) as! ReactionCell
        
        cell.reactionView.sticker = reaction
        
        return cell
        
    }
    
    fileprivate func dequeueAddStickerCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddReactionCell", for: indexPath) as! AddReactionCell
        
        cell.addImage.image = UIImage(named: "Plus-500")
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reaction = reactions[indexPath.row]
        
        switch reaction {
        case .addReaction:
            NotificationCenter.default.post(name: Notification.Name(rawValue: "AddReactionTapped"), object: nil)
            
        default:
            break
        }
    }
    
    fileprivate func stickerCanAnimate(_ sticker: MSSticker) -> Bool {
        guard let stickerImageSource = CGImageSourceCreateWithURL(sticker.imageFileURL as CFURL, nil) else {
            // If there are issues here, the "as CFURL" wasn't necessary in the WWDC video. Xcode gave you a fix it
            return false
        }
        
        let stickerImageFrameCount = CGImageSourceGetCount(stickerImageSource)
        
        return stickerImageFrameCount > 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (cell.reuseIdentifier == "ReactionCell") {
            let reactionCell = cell as! ReactionCell
            
            if stickerCanAnimate(reactionCell.reactionView.sticker!) {
                reactionCell.reactionView.startAnimating()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (cell.reuseIdentifier == "ReactionCell") {
            let reactionCell = cell as! ReactionCell
            
            if reactionCell.reactionView.isAnimating() {
                reactionCell.reactionView.stopAnimating()
            }
        }
    }
    
    
    
    
}
