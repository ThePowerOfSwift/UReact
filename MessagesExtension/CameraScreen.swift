//
//  CameraScreen.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/28/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

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
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var activeInput: AVCaptureDeviceInput!
    var videoOutputURL: URL?
    var transparencyView: UIView!
    
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
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        //Change this to a lower Preset if neccessary for file size. This will effect the cropped height/width of CGimage (on High its 1920x1080, with a cropped square of 800x800)
        
        //This is a comment to test commit
        
        let camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                
                captureSession.addInput(input)
                activeInput = input
                photoOutput = AVCapturePhotoOutput()
                
                if captureSession.canAddOutput(photoOutput) {
                    
                    captureSession.addOutput(photoOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer?.connection.videoOrientation = .portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    captureSession.startRunning()
                }
            }
            
            let transparency = createOverlay(frame: cameraView.frame, xOffset: cameraView.frame.size.width/2, yOffset: cameraView.frame.size.height/2, radius: 140)
            cameraView.addSubview(transparency)
            cameraView.bringSubview(toFront: transparency)
            
        } catch {
            
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        
        let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self
        
        if isRecording == false {
            
            isRecording = true
            
            if captureSession.canAddOutput(videoFileOutput) {
                captureSession.addOutput(videoFileOutput)
            }
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent("temp.mp4")
            
            videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: recordingDelegate)
            
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
        
        let frameCount = 20
        let delayTime: Float = 0.15
        let loopCount = 0
        
        let regift = Regift(sourceFileURL: videoOutputURL!, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
        let gifFileUrl = regift.createGif()
        
        do {
            
            gifData = try Data(contentsOf: gifFileUrl!)
        } catch {
            print("No URL found at document picked")
        }
        
        
        let gif = UIImage.gif(data: gifData!)
        previewImage.image = gif
        
        print("Regift - \(regift)")
        print("Gif saved to \(regift.createGif())")
    }
    
    @IBAction func retakeButtonPressed(_ sender: UIButton) {
        showGifPreviewView(bool: false)
    }
    
    @IBAction func keepButtonPressed(_ sender: UIButton) {
        // Save GIF
        // Transition back to collection View that now includes the newly taken GIF
        
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
        
        if isTorchOn == false {
            toggleTorch(on: true)
            isTorchOn = true
            flashToggleButton.setImage(UIImage(named: "flash-on"), for: UIControlState())
        } else {
            toggleTorch(on: false)
            isTorchOn = false
            flashToggleButton.setImage(UIImage(named: "flash-off"), for: UIControlState())
        }
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
    
    func getVideoFilePath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let videoPath = path.appendingPathComponent("/temp.mp4")
        return videoPath
    }
    
    func createOverlay(frame: CGRect, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> UIView {
        
        let overlayView = UIView(frame: frame)
        overlayView.alpha = 0.85
        overlayView.backgroundColor = Colors.peach
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path;
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    
    
}

