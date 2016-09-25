//
//  CameraScreen.swift
//  UReact
//
//  Created by Sean's Macboo Pro on 8/28/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import UIKit
import AVFoundation

let Photo = 0
let Video = 1

class CameraScreen: UIViewController, UINavigationControllerDelegate, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {

  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var tempImageView: UIImageView!
  @IBOutlet weak var takePictureButton: UIButton!
  @IBOutlet weak var switchToFrontCameraButton: UIButton!
  @IBOutlet weak var flashToggleButton: UIButton!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var previewImage: UIImageView!

  let captureSession = AVCaptureSession()
  var photoOutput: AVCapturePhotoOutput?
  var previewLayer: AVCaptureVideoPreviewLayer?
  var activeInput: AVCaptureDeviceInput!
  var captureMode: Int = Video
  var isRecording = false
  var isTorchOn = false

  let videoFileOutput = AVCaptureMovieFileOutput()
  var videoOutputURL: String?

  var imageURL: URL!
  let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
  let tempImageName = "temp_image.jpg"

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
        photoOutput = AVCapturePhotoOutput()
//        photoOutput?.availablePhotoCodecTypes = AVVideoCodecJPEG
//        photoOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]

        if captureSession.canAddOutput(photoOutput) {

          captureSession.addOutput(photoOutput)
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

  @IBAction func toggleFlash(_ sender: UIButton) {

    if isTorchOn == false {
      toggleTorch(on: true)
      isTorchOn = true
    } else {
      toggleTorch(on: false)
      isTorchOn = false
    }
  }


//    let device = activeInput.device
//
//    if (device?.hasFlash)! {
//
//      var currentMode = currentFlashMode().mode
//      let flashButtonName = currentFlashMode().name
//
//      currentMode += 1
//
//      if currentMode > 2 {
//
//        currentMode = 0
//      }
//
//      let newMode = AVCaptureFlashMode(rawValue: currentMode)!
//
//      if device?.isFlashAvailable == true {
//
//        do {
//
//
//          try device?.lockForConfiguration()
//
//          let settings = AVCapturePhotoSettings()
//          settings.flashMode = newMode
//          device?.unlockForConfiguration()
//
//          flashToggleButton.setImage(UIImage(named: flashButtonName), for: UIControlState())
//
//        } catch {
//          print("Error setting flash mode: \(error)")
//        }
//
//      }









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


  func currentFlashMode() -> (mode: Int, name: String) {

    var currentMode: Int = 0

    if captureMode == Video {

      let settings = AVCapturePhotoSettings()
      currentMode = settings.flashMode.rawValue

    } else {
      currentMode = activeInput.device.torchMode.rawValue

    }
    var flashButtonName: String!

    switch currentMode {
    case 0:
      flashButtonName = "flash-on"
      print("Flash On")
    case 1:
      flashButtonName = "flash-auto"
      print("Flash Auto")
    case 2:
      flashButtonName = "flash-off"
      print("Flash Off")

    default:
      flashButtonName = "flash-off"
      print("Flash Off - Default")
    }

    if !activeInput.device.hasFlash {
      flashButtonName = "N/A"
      print("Device has no flash")
    }

    return (currentMode, flashButtonName)
  }


  @IBAction func switchToFrontCamera(_ sender: UIButton) {

    var newPosition: AVCaptureDevicePosition!
    var newCamera: AVCaptureDevice!

    let deviceList = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)

    if activeInput.device.position == AVCaptureDevicePosition.back {
      newPosition = AVCaptureDevicePosition.front
      flashToggleButton.isHidden = true
    } else {
      newPosition = AVCaptureDevicePosition.back
      flashToggleButton.isHidden = false

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

  @IBAction func takePictureButtonPressed(_ sender: UIButton) {
    didPressTakePhoto()
  }


  func didPressTakePhoto() {

    if let videoConnection = photoOutput?.connection(withMediaType: AVMediaTypeVideo) {
      videoConnection.videoOrientation = .portrait

      let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])

      photoOutput?.capturePhoto(with: settings, delegate: self)



//      photoOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
//        (sampleBuffer, error) in
//
//
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
    }
  }

  func getVideoFilePath() -> String {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let videoPath = path.appendingPathComponent("temp.mp4")
    return videoPath
//
//    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//    var getImagePath = paths.stringByAppendingPathComponent("filename")
//    myImageView.image = UIImage(contentsOfFile: getImagePath)
  }

//  func previewImageForLocalVideo(url: NSURL) -> UIImage? {
//
//    let asset = AVAsset(url: url as URL)
//
//    print("Asset = \(asset)")
//
//    let imageGenerator = AVAssetImageGenerator(asset: asset)
//    imageGenerator.appliesPreferredTrackTransform = true
//
//    let time = asset.duration
//    print("Asset Duration = \(time)")
//    //If possible - take not the first frame (it could be completely black or white on camara's videos)
////    time.value = min(time.value, 2)
////    time = CMTimeMultiplyByFloat(time, 0.5)
//    let time1 = CMTimeMultiplyByFloat64(time, 0.1)
//    let time2 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time3 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time4 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time5 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time6 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time7 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time8 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time9 = CMTimeMultiplyByFloat64(time, 0.5)
//    let time10 = CMTimeMultiplyByFloat64(time, 0.5)
//    print("Take Asset Image at \(time)")
//
//    var times: [CMTime] = []
//
//    times.append(time1)
//
//    imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (<#CMTime#>, <#CGImage?#>, <#CMTime#>, <#AVAssetImageGeneratorResult#>, <#Error?#>) in
//      <#code#>
//    }
//
//    do {
//      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
//      return UIImage(cgImage: imageRef)
//    }
//    catch let error as NSError
//    {
//      print("Image generation failed with error \(error)")
//      return nil
//    }
//  }

//  func setPreviewImage() {
//    print("setPreviewImage Called")
//    let videoPath = getVideoFilePath()
//    let videoURL = NSURL(string: videoPath)
//    previewImage.image = previewImageForLocalVideo(url: videoURL!)
//  }

  @IBAction func recordButtonPressed(_ sender: AnyObject) {

    let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self

    if isRecording == false {

      isRecording = true

      // Do record video stuff here
      self.captureSession.addOutput(videoFileOutput)

      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let filePath = documentsURL.appendingPathComponent("temp")

      // Do recording and save the output to the `filePath`
      videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: recordingDelegate)

    } else {

      isRecording = false
      videoFileOutput.stopRecording()
    }
  }

  @IBAction func createStickerPressed(_ sender: UIButton) {
    print("Create Sticker Button Pressed")
    createGIFFromVideo()
  }

  func createGIFFromVideo() {

//    let videoURL = NSURL(string: getVideoFilePath())!
    let videoURL = NSURL(string: videoOutputURL!)
    print("VideoURL = \(videoURL)")
    let frameCount = 15
    let delayTime: Float = 0.2
    let loopCount = 0

    let regift = Regift(sourceFileURL: videoURL!, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)

    print("Regift - \(regift)")
    print("Gif saved to \(regift.createGif())")
  }


  //Delegate methods

  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    recordButton.setTitle("STOP", for: .normal)
    print("Video Started Recording")
  }

  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    recordButton.setTitle("START", for: .normal)

    print("Output file URL = \(outputFileURL)")
    videoOutputURL = outputFileURL.absoluteString

    print("Video Stopped Recording")
    print("Retrieved Video Path = \(getVideoFilePath())")
  }

//  func saveVideoToDocumentsDirectory() {
//    let fileManager = FileManager.default
//
//  }

  func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

      if photoSampleBuffer != nil {
//        let imageData = AVCapturePhotoOutput.jpegStillImageNSDataRepresentation(photoSampleBuffer)
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        let dataProvider = CGDataProvider(data: imageData as! CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)


        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)

        tempImageView.image = image
        tempImageView.isHidden = false
        saveImageLocally()

//        takePictureButton.backgroundColor = UIColor.cyan
//        takePictureButton.setTitle("Upload Image", for: UIControlState())
//        takePictureButton.removeTarget(nil, action: nil, for: .allEvents)
    }
  }

  func saveImageLocally() {
    
    let imageData: Data = UIImageJPEGRepresentation(tempImageView.image!, 1)!
    let path = documentsDirectoryPath.appendingPathComponent(tempImageName)
    imageURL = URL(fileURLWithPath: path)
    try? imageData.write(to: imageURL, options: [.atomic])
  }

  
  
}

