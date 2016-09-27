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

  var isRecording = false
  var isTorchOn = false

  let videoFileOutput = AVCaptureMovieFileOutput()
  var videoOutputURLString: String?
  var videoOutputURL: URL?


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

  func playVideo() {

    let dataPath = getVideoFilePath()

    let videoAsset = AVAsset(url: NSURL(fileURLWithPath: dataPath) as URL)
    let playerItem = AVPlayerItem(asset: videoAsset)

    let player = AVPlayer(playerItem: playerItem)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player

    self.present(playerViewController, animated: true) { 
      playerViewController.player!.play()
    }
  }

  @IBAction func createStickerPressed(_ sender: UIButton) {
    print("Create Sticker Button Pressed")
    createGIFFromVideo()
//    playVideo()
  }

  func createGIFFromVideo() {

    let path = getVideoFilePath()
    let videoURL = NSURL(string: path)

    let frameCount = 15
    let delayTime: Float = 0.2
    let loopCount = 0

    let regift = Regift(sourceFileURL: videoURL!, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)

    let gif = Regift(sourceFileURL: videoURL!, destinationFileURL: videoURL!, startTime: 0.0, duration: 2.0, frameRate: 10, loopCount: 0)

    print("Regift - \(gif)")
    print("Gif saved to \(gif.createGif())")
  }


  //Delegate methods

  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    recordButton.setTitle("STOP", for: .normal)
    print("Video Started Recording")
  }

  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    recordButton.setTitle("START", for: .normal)

    let videoData = NSData(contentsOf: outputFileURL)

    let dataPath = getVideoFilePath()
    print("dataPath = \(dataPath)")
    videoData?.write(toFile: dataPath, atomically: false)
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

  func getVideoFilePath() -> String {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let videoPath = path.appendingPathComponent("/temp.mp4")
    return videoPath
  }

  
  
}

