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
    @IBOutlet weak var gifPreviewView: UIView!
    
    let captureSession = AVCaptureSession()
    let videoFileOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var activeInput = AVCaptureDeviceInput()
    var videoOutputURL: URL?
    var transparencyView: UIView!
    var destinationURL: URL?
    var gestureStartTime: TimeInterval = 0.0
    var gestureDuration: TimeInterval = 0.0
    
    var isTorchOn = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transparencyView = createTransparencyView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Camera.createVideoCaptureSession(captureSession: captureSession, activeInput: &activeInput, fileOutPut: videoFileOutput, previewLayer: &previewLayer, cameraView: cameraView)
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
            print("No URL found at document picked")
        }
        
        let gif = UIImage.gif(data: gifData!)!
        previewImage.image = gif
    }
    
    
    @IBAction func retakeButtonPressed(_ sender: UIButton) {
        showGifPreviewView(bool: false)
    }
    
    
    @IBAction func keepButtonPressed(_ sender: UIButton) {
        Persistence.persistURL(url: (destinationURL?.path)!)
        returnToPickerView()
    }
    
    
    func returnToPickerView() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.keepReaction), object: nil)
    }
    
    
    func showGifPreviewView(bool: Bool) {
        view.bringSubview(toFront: gifPreviewView)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.transparencyView.alpha = bool ? 0.75 : 0.0
            self.gifPreviewView.alpha = bool ? 1.0 : 0.0
        })
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
        showGifPreviewView(bool: true)
    }
}

