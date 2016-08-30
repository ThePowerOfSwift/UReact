//
//  CameraScreen.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/28/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import UIKit
import AVFoundation

let CaptureModePhoto = 0
let CaptureModeVideo = 1

class CameraScreen: UIViewController, UINavigationControllerDelegate {

  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var tempImageView: UIImageView!
  @IBOutlet weak var takePictureButton: UIButton!
  @IBOutlet weak var switchToFrontCameraButton: UIButton!
  @IBOutlet weak var flashToggleButton: UIButton!

  let captureSession = AVCaptureSession()
  var stillImageOutput: AVCaptureStillImageOutput?
  var previewLayer: AVCaptureVideoPreviewLayer?
  var activeInput: AVCaptureDeviceInput!
  var captureMode: Int = CaptureModePhoto

  var imageURL: URL!
//  let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
//  let tempImageName = "temp_image.jpg"

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    previewLayer?.frame = cameraView.bounds
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    captureSession.sessionPreset = AVCaptureSessionPresetHigh

    let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    do {
      let input = try AVCaptureDeviceInput(device: camera)

      if captureSession.canAddInput(input) {

        captureSession.addInput(input)
        activeInput = input
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]

        if captureSession.canAddOutput(stillImageOutput) {

          captureSession.addOutput(stillImageOutput)
          previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
          previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
          previewLayer?.connection.videoOrientation = .portrait
          cameraView.layer.addSublayer(previewLayer!)
          captureSession.startRunning()
        }
      }

    } catch {

    }
  }

//  @IBAction func toggleFlash(_ sender: UIButton) {
//    let device = activeInput.device
//    if (device?.hasFlash)! {
//      var currentMode = currentFlashMode().mode
//      let flashButtonName = currentFlashMode().name
//
//      currentMode += 1
//      if currentMode > 2 {
//        currentMode = 0
//      }
//
//      let newMode = AVCaptureFlashMode(rawValue: currentMode)!
//
//      if (device?.isFlashModeSupported(newMode))! {
//        do {
//          try device?.lockForConfiguration()
//          device?.flashMode = newMode
//          device?.unlockForConfiguration()
//
//          flashToggleButton.setImage(UIImage(named: flashButtonName), for: UIControlState())
//
//        } catch {
//          print("Error setting flash mode: \(error)")
//        }
//      }
//    }
//  }
//
//
//  func currentFlashMode() -> (mode: Int, name: String) {
//
//    var currentMode: Int = 0
//
//    if captureMode == CaptureModePhoto {
//      currentMode = activeInput.device.flashMode.rawValue
//
//    } else {
//      currentMode = activeInput.device.torchMode.rawValue
//    }
//    var flashButtonName: String!
//
//    switch currentMode {
//    case 0:
//      flashButtonName = "flash-on"
//      print("Flash On")
//    case 1:
//      flashButtonName = "flash-auto"
//      print("Flash Auto")
//    case 2:
//      flashButtonName = "flash-off"
//      print("Flash Off")
//
//    default:
//      flashButtonName = "flash-off"
//      print("Flash Off - Default")
//    }
//
//    if !activeInput.device.hasFlash {
//      flashButtonName = "N/A"
//      print("Device has no flash")
//    }
//
//    return (currentMode, flashButtonName)
//  }
//
//  @IBAction func switchToFrontCamera(_ sender: UIButton) {
//
//    if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 1 {
//      var newPosition: AVCaptureDevicePosition!
//      if activeInput.device.position == AVCaptureDevicePosition.back {
//        newPosition = AVCaptureDevicePosition.front
//      } else {
//        newPosition = AVCaptureDevicePosition.back
//      }
//
//      var newCamera: AVCaptureDevice!
//      let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
//
////      for device in devices! {
////
////        if device.position == newPosition {
////          newCamera = device as! AVCaptureDevice
////        }
////      }
//
//      for device in devices! {
//
//        if (device as AnyObject).position == newPosition {
//          newCamera = device as! AVCaptureDevice
//        }
//      }
//
//      do {
//        let input = try AVCaptureDeviceInput(device: newCamera)
//        captureSession.beginConfiguration()
//        captureSession.removeInput(activeInput)
//
//        if captureSession.canAddInput(input) {
//          captureSession.addInput(input)
//          activeInput = input
//
//        } else {
//          captureSession.addInput(activeInput)
//        }
//        captureSession.commitConfiguration()
//
//      } catch {
//        print("Error switching cameras: \(error)")
//      }
//    }
//  }
//
//  @IBAction func takePictureButtonPressed(_ sender: UIButton) {
//    didPressTakePhoto()
//  }
//
//
//  func didPressTakePhoto() {
//
//    if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
//      videoConnection.videoOrientation = .portrait
//
//      stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
//        (sampleBuffer, error) in
//
//        if sampleBuffer != nil {
//          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//          let dataProvider = CGDataProvider(data: imageData as! CFData)
//          let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
//
//          let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
//
//          self.tempImageView.image = image
//          self.tempImageView.isHidden = false
//          self.saveImageLocally()
//
//          self.takePictureButton.backgroundColor = UIColor.cyan
//          self.takePictureButton.setTitle("Upload Image", for: UIControlState())
//          self.takePictureButton.removeTarget(nil, action: nil, for: .allEvents)
//        }
//      })
//    }
//  }
//
//  
//  func saveImageLocally() {
//    
//    let imageData: Data = UIImageJPEGRepresentation(tempImageView.image!, 1)!
//    let path = documentsDirectoryPath.appendingPathComponent(tempImageName)
//    imageURL = URL(fileURLWithPath: path)
//    try? imageData.write(to: imageURL, options: [.atomic])
//  }
  
  
  
}

