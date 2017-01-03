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
    var previewLayer: AVCaptureVideoPreviewLayer?
    var activeInput: AVCaptureDeviceInput!
    var videoOutputURL: URL?
    var transparencyView: UIView!
    var gif: UIImage?
    var destinationURL: URL?
    
    var isRecording = false
    var isTorchOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transparencyView = createTransparencyView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createVideoCaptureSession()
    }
    
    func createVideoCaptureSession() {
        
        captureSession.sessionPreset = AVCaptureSessionPresetMedium
        
        let camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                
                captureSession.addInput(input)
                activeInput = input
                
                if captureSession.canAddOutput(videoFileOutput) {
                    captureSession.addOutput(videoFileOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer?.connection.videoOrientation = .portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    captureSession.startRunning()
                }
            }
            
            createCameraTransparency()
            
        } catch {
            
        }
        
    }
    
    func createCameraTransparency() {
        
        let cameraTransparency = CameraTransparency()
        
        let view = cameraTransparency.createOverlay(frame: cameraView.frame, xOffset: cameraView.frame.size.width/2, yOffset: cameraView.frame.size.height/2, radius: 140)
        cameraView.addSubview(view)
        cameraView.bringSubview(toFront: view)
    }
    
    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        
        let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self
        
        if isRecording == false {
            
            isRecording = true
            videoFileOutput.startRecording(toOutputFileURL: Persistence.createTempFilePath(), recordingDelegate: recordingDelegate)
            
        } else {
            isRecording = false
            videoFileOutput.stopRecording()
        }
    }
    
    @IBAction func createStickerPressed(_ sender: UIButton) {
        createGIFFromVideo()
    }
    
    func createGIFFromVideo() {
        
        var gifData: Data?
        
        let frameCount = 7
        let loopCount = 0
        destinationURL = Persistence.createGifFilePath()
        
        let regift = Regift(sourceFileURL: videoOutputURL!, destinationFileURL: destinationURL, startTime: 0.0, duration: 3.0, frameRate: frameCount, loopCount: loopCount)
        
        //If duration of video is less than the stated 2.5 seconds, it crashes.
        let gifDataURL = regift.createGif()
        
        do {
            gifData = try Data(contentsOf: gifDataURL!)
        } catch {
            print("No URL found at document picked")
        }
        
        gif = UIImage.gif(data: gifData!)!
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
    
    
    //Delegate methods
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        recordButton.setTitle("STOP", for: .normal)
        print("Video Started Recording")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        recordButton.setTitle("START", for: .normal)
        
        videoOutputURL = outputFileURL
        createGIFFromVideo()
        showGifPreviewView(bool: true)
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        
        let image = isTorchOn ? #imageLiteral(resourceName: "flash-off") : #imageLiteral(resourceName: "flash-on")
        
        isTorchOn = isTorchOn ? false : true
        toggleTorch(on: isTorchOn)
        flashToggleButton.setImage(image, for: .normal)
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
                
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    
    @IBAction func switchToFrontCamera(_ sender: UIButton) {
        
        var newPosition: AVCaptureDevicePosition!
        var newCamera: AVCaptureDevice!
        
        let deviceList = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        if activeInput.device.position == AVCaptureDevicePosition.back {
            newPosition = AVCaptureDevicePosition.front
            flashToggleButton.alpha = 0.0
        } else {
            newPosition = AVCaptureDevicePosition.back
            flashToggleButton.alpha = 1.0
        }
        
        for device in (deviceList?.devices)! {
            
            if (device as AnyObject).position == newPosition {
                newCamera = device
            }
        }
        
        do {
            
            let input = try AVCaptureDeviceInput(device: newCamera)
            captureSession.beginConfiguration()
            captureSession.removeInput(activeInput)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
                
            } else {
                captureSession.addInput(activeInput)
            }
            captureSession.commitConfiguration()
            
        } catch {
            print("Error switching cameras: \(error)")
        }
    }
    
}

