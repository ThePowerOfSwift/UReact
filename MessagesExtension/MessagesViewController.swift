//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Sean's Macboo Pro on 6/27/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import UIKit
import Messages
import AVFoundation

class MessagesViewController: MSMessagesAppViewController {

  var reactionsPickerViewController: ReactionsPickerViewController!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    addObservers()
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: nil)
    }

  override func willBecomeActive(with conversation: MSConversation) {
    presentViewController(withPresentationStyle: presentationStyle)
  }

  override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    super.didTransition(to: presentationStyle)
  }

  override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    presentViewController(withPresentationStyle: presentationStyle)

  }

  func tappedAddNewReaction() {
    requestPresentationStyle(.expanded)
  }

  func addObservers() {
      NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.tappedAddNewReaction), name:NSNotification.Name(rawValue: "AddReactionTapped"), object: nil)
  }
}

extension MSMessagesAppViewController {

  func presentViewController(withPresentationStyle style: MSMessagesAppPresentationStyle) {
    let controller: UIViewController

    if style == .compact {
      controller = instantiateReactionsPickerViewController()
    } else {
      controller = instantiateCameraViewController()
    }

    for child in childViewControllers {
      child.willMove(toParentViewController: .none)
      child.view.removeFromSuperview()
      child.removeFromParentViewController()
    }

    addChildViewController(controller)

    controller.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(controller.view)

    NSLayoutConstraint.activate([
      controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      controller.view.topAnchor.constraint(equalTo: view.topAnchor),
      controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])

    controller.didMove(toParentViewController: self)
  }

  func instantiateCameraViewController() -> UIViewController {
    guard let controller = storyboard?.instantiateViewController(withIdentifier: "CameraScreen") as? CameraScreen else { fatalError("Unable to instantiate a camera screen") }

    return controller
  }

  func instantiateReactionsPickerViewController() -> UIViewController {
    guard let controller = storyboard?.instantiateViewController(withIdentifier: "ReactionsPickerViewController") as? ReactionsPickerViewController else { fatalError("Unable to instantiate a camera screen") }

    return controller
  }
}
