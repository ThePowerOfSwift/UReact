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
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var retakeButtonTopSpace: NSLayoutConstraint!
    @IBOutlet weak var retakeButtonTrailingSpace: NSLayoutConstraint!
    
    @IBOutlet var previewViews: [UIView]!
    @IBOutlet var recordViews: [UIView]!
    
    let captureSession = AVCaptureSession()
    let videoFileOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var activeInput = AVCaptureDeviceInput()
    var videoOutputURL: URL?
    var destinationURL: URL?
    var gestureStartTime: TimeInterval = 0.0
    var gestureDuration: TimeInterval!
    
    var isTorchOn = false
    var isBackCamera = false
    var progressTimer: Timer!
    var progress: CGFloat! = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRecordButtonTargets()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.layoutIfNeeded()
        
        Camera.createVideoCaptureSession(captureSession: self.captureSession, activeInput: &self.activeInput, fileOutPut: self.videoFileOutput, previewLayer: &self.previewLayer, cameraView: self.cameraView)
        
        retakeButton.layer.borderWidth = 2.0
        retakeButton.layer.borderColor = Colors.uReactRed.cgColor
        previewImage.setPreviewShadow()
        adjustPreview()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size: CGSize = UIScreen.main.bounds.size
        
        if (size.width / size.height > 1) {
            
            adjustForiPhone5()
            
            previewLayer.connection.videoOrientation = .landscapeRight
            previewLayer.frame = self.view.bounds
            cameraView.frame = self.view.bounds
            Camera.drawCameraSqureOverlay(cameraView: cameraView)
//            previewImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            print("landscape")
            
        } else {
            
            previewLayer.connection.videoOrientation = .portrait
            previewLayer.frame = self.view.bounds
            cameraView.frame = self.view.bounds
            Camera.drawCameraSqureOverlay(cameraView: cameraView)
//            previewImage.transform = .identity
            
            print("portrait")
        }
    }

    
    @IBAction func toggleFlash(_ sender: UIButton) {
        isTorchOn = isTorchOn ? false : true
        Camera.toggleTorch(on: isTorchOn)
        
        let image = isTorchOn ? #imageLiteral(resourceName: "flash-off") : #imageLiteral(resourceName: "flash-on")
        flashToggleButton.setImage(image, for: .normal)
    }

    
    @IBAction func flipCamera(_ sender: UIButton) {
        Camera.flipCamera(activeInput: &activeInput, session: captureSession, button: flashToggleButton)
        isBackCamera = isBackCamera ? false : true
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
            print(".ended called. Gesture Duration = \(gestureDuration)")
            recordButton.buttonState = .idle
        
        default:
            break
        }
    }
    
    
    // Record Button functions
    func addRecordButtonTargets() {
        recordButton.addTarget(self, action: #selector(CameraScreen.record), for: .touchDown)
        recordButton.addTarget(self, action: #selector(CameraScreen.stop), for: UIControlEvents.touchUpInside)
    }
    
    
    func record() {
        dispatchDelayedOnMainThread(seconds: 0.2, action: {
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(CameraScreen.updateProgress), userInfo: nil, repeats: true)
        })
    }
    
    
    func updateProgress() {
        
        let maxDuration: CGFloat = 3.0 // max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
            recordButton.sendActions(for: .touchCancel)
            recordButton.buttonState = .idle
        }
    }
    
    
    func stop() {
        self.progressTimer.invalidate()
    }
    
    
    func createGIFFromVideo() {
        
        var gifData: Data?
        var gifDuration: TimeInterval?
        
        let frameCount = 7
        let loopCount = 0
        
        if gestureDuration != nil {
            gifDuration = gestureDuration < 2.7 ? gestureDuration : 2.7
        } else {
            gifDuration = 2.7
        }

        print("GIF Duration = \(gifDuration)")
        
        destinationURL = Persistence.createGifFilePath()
        
        let regift = Regift(sourceFileURL: videoOutputURL!, destinationFileURL: destinationURL, startTime: 0.0, duration: Float(gifDuration!), frameRate: frameCount, loopCount: loopCount)
        
        print(regift)
        let gifDataURL = regift.createGif()
        
        gestureDuration = nil
        
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
        recordButton.buttonState = .idle
        progress = 0.0
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
            UIView.animate(withDuration: 0.1, animations: {
                item.alpha = bool ? 0.0 : 1.0
            })
        }
        
        if isBackCamera {
            UIView.animate(withDuration: 0.4, animations: {
                self.flashToggleButton.alpha = bool ? 0.0 : 1.0
            })
        }
    }
    
    
    func adjustPreview() {
        previewImage.layoutIfNeeded()
        GifEditor.adjustPreviewForScreenSize(width: previewWidthConstraint, height: previewHeightConstraint)
    }
    
    func adjustForiPhone5() {
        if DeviceTypes.iPhone5 || DeviceTypes.iPhone7Zoomed {
            retakeButtonTopSpace.constant = -150
            retakeButtonTrailingSpace.constant = 60
        }
    }
    
    
    // MARK: Capture Delegate Methods
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("Did Start Recording Fired")
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("Did Finish Recording fired.")
        videoOutputURL = outputFileURL
        print(outputFileURL)
        createGIFFromVideo()
        showGifPreview(bool: true)
        stop()
    }
}

