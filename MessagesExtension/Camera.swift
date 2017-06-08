//
//  Camera.swift
//  UReact
//
//  Created by Sean Allen on 1/2/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class Camera: NSObject {
    
    class func createCaptureDevice() -> AVCaptureDevice {
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        return camera!
    }
    
    class func createVideoCaptureSession(captureSession: AVCaptureSession, camera: AVCaptureDevice, activeInput: inout AVCaptureDeviceInput, fileOutPut: AVCaptureMovieFileOutput, previewLayer: inout AVCaptureVideoPreviewLayer, cameraView: UIView) {
        
//        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
                
                if captureSession.canAddOutput(fileOutPut) {
                    
                    captureSession.addOutput(fileOutPut)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    previewLayer.connection?.videoOrientation = .portrait
                    cameraView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            }
            drawCameraSqureOverlay(cameraView: cameraView)
            
        } catch {
            
        }
    }
    
    class func drawCameraSqureOverlay(cameraView: UIView) {
        
        for view in cameraView.subviews {
            view.removeFromSuperview()
        }
        
        var width: CGFloat = 215
        var height: CGFloat = 215
        
        if DeviceTypes.iPhone5 || DeviceTypes.iPhone7Zoomed {
            width = 190
            height = 190
        } else if DeviceTypes.iPhone7PlusStandard {
            width = 240
            height = 240
        } else if DeviceTypes.iPad {
            width = 460
            height = 460
        }
        
        let cameraOverlay = CameraOverlay()
        let frame = cameraView.bounds
        let xOffset = (cameraView.bounds.size.width/2) - (width/2)
        let yOffset = (cameraView.bounds.size.height/2) - (height/2)
        
        
        let view = cameraOverlay.createSquareOverlay(frame: frame, xOffset: xOffset, yOffset: yOffset, visibleWidth: width, visibleHeight: height)
        
        
        cameraView.addSubview(view)
        cameraView.bringSubview(toFront: view)
    }

    
//    Creates a circle overlay
    
//    class func createCircleCameraOverlay(cameraView: UIView) {
//        let cameraOverlay = CameraOverlay()
//        
//        var radius: CGFloat = 120
//        
//        if DeviceTypes.iPhone5 || DeviceTypes.iPhone7Zoomed {
//            radius = 100
//        } else if DeviceTypes.iPhone7PlusStandard {
//            radius = 130
//        } else if DeviceTypes.iPad {
//            radius = 240
//        }
//      
//        let view = cameraOverlay.createCircleOverlay(frame: cameraView.bounds, xOffset: cameraView.bounds.size.width/2, yOffset: cameraView.bounds.size.height/2, radius: radius)
//        view.setGradientBackground(top: Colors.veryDarkGrey, bottom: Colors.lightGrey)
//        
//        cameraView.addSubview(view)
//        cameraView.bringSubview(toFront: view)
//    }
    
    
    class func toggleTorch(on: Bool) {
        
//        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaType.video) else { return }
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            } catch {
                // Show error pop up
                print("Torch could not be used")
            }
        } else {
            // Show error pop up
            print("Torch is not available")
        }
    }
    
    
    class func flipCamera(activeInput: inout AVCaptureDeviceInput, session: AVCaptureSession, button: UIButton) {
        
        var newPosition: AVCaptureDevice.Position!
        var newCamera: AVCaptureDevice!
        let deviceList = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        let isBackCamera = activeInput.device.position == AVCaptureDevice.Position.back
        
        newPosition = isBackCamera ? .front : .back
        button.alpha = isBackCamera ? 0.0 : 1.0
        
        for device in (deviceList.devices) {
            if (device as AnyObject).position == newPosition {
                newCamera = device
            }
        }
        do {
            let input = try AVCaptureDeviceInput(device: newCamera)
            session.beginConfiguration()
            session.removeInput(activeInput)
            
            if session.canAddInput(input) {
                session.addInput(input)
                activeInput = input
                
            } else {
                session.addInput(activeInput)
            }
            session.commitConfiguration()
            
        } catch {
            // Show error pop up
            print("Error switching cameras: \(error)")
        }
    }
}
