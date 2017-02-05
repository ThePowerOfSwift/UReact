//
//  CameraScreen.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/28/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class CameraScreen: UIViewController, UINavigationControllerDelegate, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashToggleButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var previewViews: [UIView]!
    @IBOutlet var recordViews: [UIView]!
    
    let captureSession = AVCaptureSession()
    let videoFileOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var activeInput = AVCaptureDeviceInput()
    var videoOutputURL: URL?
    var destinationURL: URL?
    var gestureStartTime: TimeInterval = 0.0
    var gestureDuration: TimeInterval = 0.0
    
    var isTorchOn = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.layoutIfNeeded()
        Camera.createVideoCaptureSession(captureSession: captureSession, activeInput: &activeInput, fileOutPut: videoFileOutput, previewLayer: &previewLayer, cameraView: cameraView)
        
        retakeButton.layer.borderWidth = 2.0
        retakeButton.layer.borderColor = Colors.uReactRed.cgColor
        previewImage.setPreviewShadow()
        adjustPreview()
        showGifPreview(bool: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }
    
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        isTorchOn = isTorchOn ? false : true
        Camera.toggleTorch(on: isTorchOn)
        
        let image = isTorchOn ? #imageLiteral(resourceName: "flash-off") : #imageLiteral(resourceName: "flash-on")
        flashToggleButton.setImage(image, for: .normal)
    }

    
    @IBAction func flipCamera(_ sender: UIButton) {
        Camera.flipCamera(activeInput: &activeInput, session: captureSession, button: flashToggleButton)
    }

    
    @IBAction func recordButtonHeld(_ sender: UILongPressGestureRecognizer) {
        
        let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self
        
        switch sender.state {
        case .began:
            videoFileOutput.startRecording(toOutputFileURL: Persistence.createTempFilePath(), recordingDelegate: recordingDelegate)
            gestureStartTime = Date.timeIntervalSinceReferenceDate
            
        case .ended:
            videoFileOutput.stopRecording()
            gestureDuration = Date.timeIntervalSinceReferenceDate - gestureStartTime
            
        default:
            break
        }
    }
    
    
    func createGIFFromVideo() {
        
        var gifData: Data?
        
        let frameCount = 7
        let loopCount = 0
        let gifDuration = gestureDuration < 3.0 ? gestureDuration : 3.0
        
        destinationURL = Persistence.createGifFilePath()
        
        let regift = Regift(sourceFileURL: videoOutputURL!, destinationFileURL: destinationURL, startTime: 0.0, duration: Float(gifDuration), frameRate: frameCount, loopCount: loopCount)

        let gifDataURL = regift.createGif()
        
        do {
            gifData = try Data(contentsOf: gifDataURL!)
        } catch {
            
            // show error pop up here
            print("No URL found at document picked")
        }
        
        let gif = UIImage.gif(data: gifData!)!
        previewImage.image = gif
    }
    
    
    @IBAction func retakeButtonPressed(_ sender: UIButton) {
        showGifPreview(bool: false)
    }
    
    
    @IBAction func keepButtonPressed(_ sender: UIButton) {
        Persistence.persistURL(url: (destinationURL?.path)!)
        returnToPickerView()
    }
    
    
    func returnToPickerView() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.keepReaction), object: nil)
    }
    
    
    func showGifPreview(bool: Bool) {
        
        for item in previewViews {
            view.bringSubview(toFront: item)
            UIView.animate(withDuration: 0.4, animations: {
                item.alpha = bool ? 1.0 : 0.0
            })
        }
        
        for item in recordViews {
            UIView.animate(withDuration: 0.4, animations: {
                item.alpha = bool ? 0.0 : 1.0
            })
        }
    }
    
    
    func adjustPreview() {
        previewImage.layoutIfNeeded()
        GifEditor.adjustPreviewForScreenSize(width: previewWidthConstraint, height: previewHeightConstraint)
    }
    
    
    // MARK: Capture Delegate Methods
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        // Update Button Visuals accordingly
        recordButton.setTitle("RECORDING", for: .normal)
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        // Update Button Visuals accordingly
        recordButton.setTitle("FINISHED", for: .normal)
        videoOutputURL = outputFileURL
        createGIFFromVideo()
        showGifPreview(bool: true)
    }
}

