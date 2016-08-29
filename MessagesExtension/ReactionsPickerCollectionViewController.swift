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

  enum CollectionViewItem {
    case reactionSticker(MSSticker)
    case addReaction
  }

  var reactions: [CollectionViewItem]!

  override func viewDidLoad() {
      super.viewDidLoad()

    reactions = [CollectionViewItem]()
    reactions.append(.addReaction)
    loadReactions()

  }

  func loadReactions() {
    createSticker(assetName: "dwarf", localizedDescription: "Ninja image")
    createSticker(assetName: "earthMage", localizedDescription: "Angel image")
    createSticker(assetName: "samurai", localizedDescription: "Samurai image")
    createSticker(assetName: "angel", localizedDescription: "Ninja image")
    createSticker(assetName: "bandit", localizedDescription: "Angel image")
  }

  func createSticker(assetName: String, localizedDescription: String) {

    guard let stickerPath = Bundle.main.path(forResource: assetName, ofType: "png") else {
      print("Could not create sticker path for \(assetName)")
      return
    }

    let stickerURL = URL(fileURLWithPath: stickerPath)

    let sticker: MSSticker
    do {
      try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
      reactions.append(.reactionSticker(sticker))
    } catch {
      print(error)
      return
    }
  }


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
  

  private func dequeueReactionStickerCell(for reaction: MSSticker, at indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReactionCell", for: indexPath) as! ReactionCell

    cell.reactionView.sticker = reaction

    return cell

  }

  private func dequeueAddStickerCell(at indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddReactionCell", for: indexPath) as! AddReactionCell

    cell.addImage.image = UIImage(named: "Plus-500")

    return cell
    
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let reaction = reactions[indexPath.row]

    switch reaction {
    case .addReaction:

      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddReactionTapped"), object: nil)
      print("Observer - Notification Posted on Add Tap")
      
      // Code here to present expanded view
//      delegate.tappedAddNewReaction()    Might not need the delegate. Just call this function

    default:
      break
    }
  }

  private func stickerCanAnimate(sticker: MSSticker) -> Bool {
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

      if stickerCanAnimate(sticker: reactionCell.reactionView.sticker!) {
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
