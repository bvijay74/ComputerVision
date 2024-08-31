//
//  CameraView.swift
//  TextScope
//
//  Created by Vijayakumar B on 30/08/24.
//

import UIKit
import SwiftUI
import AVFoundation
import Vision

class CameraViewController : UIViewController {
    var outputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private var cameraPermitted = false
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let dispatchQueue = DispatchQueue(label: "sessionQueue")
    private var capturePreviewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCameraPermission()
        
        dispatchQueue.async { [unowned self] in
            guard cameraPermitted else { return }
            
            self.startCapture()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.capturePreviewLayer.frame = self.view.bounds
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermitted = true
                    
            case .notDetermined:
                requestCameraPermission()
                        
            default:
                cameraPermitted = false
        }
    }

    func requestCameraPermission() {
        dispatchQueue.suspend()
        
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] permission in
            self.cameraPermitted = permission
            self.dispatchQueue.resume()
        }
    }

    func startCapture() {
        guard let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else { return }
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.sessionPreset = .photo
        guard captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)

        capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.capturePreviewLayer)
        }
        
        videoOutput.setSampleBufferDelegate(self.outputDelegate, queue: DispatchQueue(label: "videoDispatchQueue"))
        captureSession.addOutput(videoOutput)
        
        updateOrientation()
        
        self.captureSession.startRunning()
    }
    
    @objc private func deviceOrientationChange() {
        updateOrientation()
    }
    
    func updateOrientation() {
        switch UIDevice.current.orientation {
            case UIDeviceOrientation.portraitUpsideDown:
            if self.capturePreviewLayer.connection?.isVideoRotationAngleSupported(270) == true {
                self.capturePreviewLayer.connection?.videoRotationAngle = 270
            }
            self.videoOutput.connection(with: .video)?.videoRotationAngle = 270
               
            case UIDeviceOrientation.landscapeLeft:
            if self.capturePreviewLayer.connection?.isVideoRotationAngleSupported(0) == true {
                self.capturePreviewLayer.connection?.videoRotationAngle = 0
            }
            self.videoOutput.connection(with: .video)?.videoRotationAngle = 0

            case UIDeviceOrientation.landscapeRight:
            if self.capturePreviewLayer.connection?.isVideoRotationAngleSupported(180) == true {
                self.capturePreviewLayer.connection?.videoRotationAngle = 180
            }
            self.videoOutput.connection(with: .video)?.videoRotationAngle = 180
                     
            case UIDeviceOrientation.portrait:
            if self.capturePreviewLayer.connection?.isVideoRotationAngleSupported(90) == true {
                self.capturePreviewLayer.connection?.videoRotationAngle = 90
            }
            self.videoOutput.connection(with: .video)?.videoRotationAngle = 90
            
            default:
            if self.capturePreviewLayer.connection?.isVideoRotationAngleSupported(90) == true {
                self.capturePreviewLayer.connection?.videoRotationAngle = 90
            }
            self.videoOutput.connection(with: .video)?.videoRotationAngle = 90
            break
        }
    }
}

struct CameraView : UIViewControllerRepresentable {
    @Binding var detectedText: String
    @Binding var error: Error?
    
    class Coordinator : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var lastProcTime: TimeInterval = 0.0
        let procInterval: TimeInterval = 2.0
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let currentTime = CACurrentMediaTime()
            if parent.error == nil {
                guard currentTime - lastProcTime >= procInterval else { return }
            }
            lastProcTime = currentTime
            
            
            guard let cgImage = sampleBufferToCGImage(sampleBuffer: sampleBuffer) else { return }
            guard let grayScaleImage = imageToGrayscale(cgImage: cgImage) else { return }
            
            var requestOptions: [VNImageOption: Any] = [:]
            if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                requestOptions = [.cameraIntrinsics: cameraData]
            }
            
            let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                
                self.onTextRead(textObservations: results)
            }
            textRecognitionRequest.minimumTextHeight = 0.05
            textRecognitionRequest.recognitionLevel = .accurate
            
            
            let requestHandler = VNImageRequestHandler(cgImage: grayScaleImage, options: requestOptions)
            
            do {
                parent.error = nil
                try requestHandler.perform([textRecognitionRequest])
            }
            catch {
                parent.error = error
            }
        }
        
        func onTextRead(textObservations: [VNRecognizedTextObservation]) {
            var text: String = ""
            
            for observation in textObservations {
                if let topCandidate = observation.topCandidates(1).first {
                    text += topCandidate.string + "\n"
                }
            }
            
            parent.detectedText = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.outputDelegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
