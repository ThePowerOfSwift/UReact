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

  //PNG Version
//  func loadReactions() {
//    createSticker("dwarf", localizedDescription: "Ninja image")
//    createSticker("earthMage", localizedDescription: "Angel image")
//    createSticker("samurai", localizedDescription: "Samurai image")
//    createSticker("angel", localizedDescription: "Ninja image")
//    createSticker("bandit", localizedDescription: "Angel image")
//  }

  //GIF Version
  func loadReactions() {
//    createSticker("maze", localizedDescription: "Maze")
//    createSticker("yes", localizedDescription: "Yes")
//    createSticker("crab", localizedDescription: "crab")

    createCircleGif("maze", localizedDescription: "Maze")
  }


// PNG Version

//  func createSticker(_ assetName: String, localizedDescription: String) {
//
//    guard let stickerPath = Bundle.main.path(forResource: assetName, ofType: "png") else {
//      print("Could not create sticker path for \(assetName)")
//      return
//    }
//
//    let stickerURL = URL(fileURLWithPath: stickerPath)
//
//    let sticker: MSSticker
//    do {
//      try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
//      reactions.append(.reactionSticker(sticker))
//    } catch {
//      print(error)
//      return
//    }
//  }


  //GIF Cropping Test
  func createCircleGif(_ assetName: String, localizedDescription: String) {

    guard let stickerPath = Bundle.main.path(forResource: assetName, ofType: "gif") else {
      print("Could not create sticker path for \(assetName)")
      return
    }


    // Create Gif and crop to circle
    let sampleGif = UIImage.gif(name: assetName)
//    let sampleGif = UIImage(named: assetName)
    let circleGif = sampleGif?.circle


    // Save cropped GIF to Document Directory as data (not sure it works as JPEGRepresentation)
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("gifSticker.gif")

    print(paths)

//    let gifData = UIImageJPEGRepresentation(circleGif!, 0.5)
    let gifData = UIImagePNGRepresentation(circleGif!)


    fileManager.createFile(atPath: paths as String, contents: gifData, attributes: nil)

    let gifURL = URL(fileURLWithPath: paths)


    // Create Sticker from saved File Path
    let sticker: MSSticker
    do {
      try sticker = MSSticker(contentsOfFileURL: gifURL, localizedDescription: localizedDescription)
      reactions.append(.reactionSticker(sticker))
    } catch {
      print(error)
      return
    }

  }

  //GIF Version
  func createSticker(_ assetName: String, localizedDescription: String) {

    guard let stickerPath = Bundle.main.path(forResource: assetName, ofType: "gif") else {
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
