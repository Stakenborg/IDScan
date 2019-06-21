//
//  ViewController.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/11/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit
import AVFoundation

public protocol ScanDelegate: class {
    func scanSucceeded(onScanViewController scanViewController: ScanViewController, scanResult: ScanResult)
    func scanCancelled(onScanViewController scanViewController: ScanViewController)
}

public class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let overlayView = OverlayView(scanType: .frontLicense)
    private let textHelpLabel = UILabel()
    private var imageAcceptanceView: ImageAcceptanceView?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?
    private let metadataOutput = AVCaptureMetadataOutput()
    private var timer: Timer?
    private var hasPassedMetadataFilter = false
    private var shouldTakePicture = false
    private var currentImage: UIImage?
    private var frontImage: UIImage?
    private var scanType: ScanType = .frontLicense {
        didSet {
            overlayView.scanType = scanType
            guard captureSession != nil else { return } // If you set the object types before the captureSession is enabled, you'll crash the app
            hasPassedMetadataFilter = false
            switch scanType {
            case .backLicense: metadataOutput.metadataObjectTypes = [.pdf417]
            default:           metadataOutput.metadataObjectTypes = [.face]
            }
        }
    }
    public weak var delegate: ScanDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let scanDocumentLabel = UILabel()
        scanDocumentLabel.translatesAutoresizingMaskIntoConstraints = false
        scanDocumentLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        scanDocumentLabel.text = "Scan Document"
        
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        let scanIDButton = UIButton(type: .system)
        scanIDButton.translatesAutoresizingMaskIntoConstraints = false
        scanIDButton.tintColor = .sharpBlue
        scanIDButton.contentHorizontalAlignment = .left
        scanIDButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        scanIDButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        scanIDButton.layer.cornerRadius = 5.0
        scanIDButton.layer.borderWidth = 2.0
        scanIDButton.layer.borderColor = UIColor.sharpBlue.cgColor
        scanIDButton.setTitle("Scan Driver's License or ID", for: .normal)
        scanIDButton.setImage(UIImage(named: "id", in: Bundle(for: ScanViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        scanIDButton.addTarget(self, action: #selector(presentIDScan(_:)), for: .touchUpInside)
        
        let scanPassportButton = UIButton(type: .system)
        scanPassportButton.translatesAutoresizingMaskIntoConstraints = false
        scanPassportButton.tintColor = .sharpBlue
        scanPassportButton.contentHorizontalAlignment = .left
        scanPassportButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        scanPassportButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        scanPassportButton.layer.cornerRadius = 5.0
        scanPassportButton.layer.borderWidth = 2.0
        scanPassportButton.layer.borderColor = UIColor.sharpBlue.cgColor
        scanPassportButton.setTitle("Scan Passport", for: .normal)
        scanPassportButton.setImage(UIImage(named: "passport", in: Bundle(for: ScanViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        scanPassportButton.addTarget(self, action: #selector(presentPassportScan(_:)), for: .touchUpInside)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .clear
        overlayView.backButton.addTarget(self, action: #selector(dismissScan), for: .touchUpInside)
        overlayView.captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        overlayView.isHidden = true
        
        view.addSubview(scanDocumentLabel)
        view.addSubview(closeButton)
        view.addSubview(scanIDButton)
        view.addSubview(scanPassportButton)
        view.addSubview(overlayView)
        
        scanDocumentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scanDocumentLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        scanIDButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        scanIDButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        scanIDButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -5).isActive = true
        scanIDButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        scanPassportButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        scanPassportButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        scanPassportButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 5).isActive = true
        scanPassportButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        overlayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            scanDocumentLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            scanDocumentLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        }
    }
    
    func displayError(message: String = "An error occurred. Please try again.") {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped(_ button: UIButton) {
        delegate?.scanCancelled(onScanViewController: self)
    }
    
    @objc func presentIDScan(_ button: UIButton) {
        scanType = .frontLicense
        presentScan()
    }
    
    @objc func presentPassportScan(_ button: UIButton) {
        scanType = .passport
        presentScan()
    }
    
    func displayCaptureSession() {
        guard let previewLayer = previewLayer else { return }
        view.layer.addSublayer(previewLayer)
        
        overlayView.isHidden = false
        view.bringSubviewToFront(overlayView)
        if videoOutput != nil { // Keep the manual capture button hidden to allow for automatic scanning to start with unless the camera doesn't support UHD video
            overlayView.fadeInCaptureButton()
        }
        
        captureSession?.startRunning()
        restartTimer()
    }
    
    func presentScan() {
        guard captureSession == nil else {
            displayCaptureSession()
            return
        }
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            displayError()
            return
        }
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.isSubjectAreaChangeMonitoringEnabled = true
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
        } catch {
            // This shouldn't really happen, but we don't really need to do anything with the error if it does
        }
        
        let deviceInput: AVCaptureDeviceInput
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            displayError()
            return
        }
        
        captureSession.addInput(deviceInput)
        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String : Any]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: .main)
            
            captureSession.addOutput(videoOutput)
            self.videoOutput = videoOutput
        } else {
            captureSession.sessionPreset = .photo
        }
        
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput), captureSession.canAddOutput(metadataOutput) else {
            displayError()
            return
        }
        captureSession.addOutput(photoOutput)
        self.photoOutput = photoOutput
        
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = scanType == .backLicense ? [.pdf417] : [.face]
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        self.captureSession = captureSession
        displayCaptureSession()
    }
    
    @objc func dismissScan() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        overlayView.isHidden = true
        timer?.invalidate()
        timer = nil
        shouldTakePicture = false
    }
    
    @objc func captureImage() {
        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        shouldTakePicture = false
        restartTimer()
    }
    
    func presentImage(_ image: UIImage) {
        dismissScan()
        currentImage = image
        
        let imageAcceptanceView = ImageAcceptanceView(image: image)
        imageAcceptanceView.translatesAutoresizingMaskIntoConstraints = false
        imageAcceptanceView.acceptButton.addTarget(self, action: #selector(acceptImage), for: .touchUpInside)
        imageAcceptanceView.retryButton.addTarget(self, action: #selector(retryImage), for: .touchUpInside)
        view.addSubview(imageAcceptanceView)
        
        imageAcceptanceView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageAcceptanceView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        if #available(iOS 11.0, *) {
            imageAcceptanceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            imageAcceptanceView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            imageAcceptanceView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imageAcceptanceView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        self.imageAcceptanceView = imageAcceptanceView
    }
    
    func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.shouldTakePicture = true
        }
    }
    
    func isImageValid(_ image: CIImage, forDetectorType detectorType: String, shouldDisplayErrors: Bool) -> Bool {
        switch detectorType {
        case CIDetectorTypeFace:
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            
            guard faceDetector?.features(in: image).count ?? 0 > 0 else {
                print("no face detected")
                if shouldDisplayErrors {
                    displayError(message: "No face detected in image. Make sure picture is clear, in focus, and has no glare. Please try again.")
                }
                return false
            }
            return true
        case CIDetectorTypeRectangle:
            let rectangleDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            
            guard let features = rectangleDetector?.features(in: image), features.count > 0 else {
                print ("no rectangle detected")
                if shouldDisplayErrors {
                    displayError(message: "Could not detect all four edges of document. Please try again.")
                }
                return false
            }
            
            for feature in features {
                guard feature.type == CIFeatureTypeRectangle else { continue }
                if feature.bounds.width/image.extent.width > 0.6 &&
                    feature.bounds.height/image.extent.height > 0.6 &&
                    feature.bounds.origin.x/image.extent.width > 0.05 &&
                    feature.bounds.origin.y/image.extent.height > 0.05 &&
                    (feature.bounds.width+feature.bounds.origin.x)/image.extent.width < 0.95 &&
                    (feature.bounds.height+feature.bounds.origin.y)/image.extent.height < 0.95 {
                    break
                } else {
                    print("rectangle too small")
                    if shouldDisplayErrors {
                        displayError(message: "Document is too far from the camera. Please move it closer and try again.")
                    }
                    return false
                }
            }
            return true
        default:
            return false
        }
    }
    
    func processImage(_ image: CIImage, didTakePictureManually: Bool = false) {
        switch scanType {
        case .frontLicense:
            guard isImageValid(image, forDetectorType: CIDetectorTypeFace, shouldDisplayErrors: didTakePictureManually) else { return }
            guard isImageValid(image, forDetectorType: CIDetectorTypeRectangle, shouldDisplayErrors: didTakePictureManually) else { return }
        case .backLicense:
            guard isImageValid(image, forDetectorType: CIDetectorTypeRectangle, shouldDisplayErrors: didTakePictureManually) else { return }
        case .passport:
            guard isImageValid(image, forDetectorType: CIDetectorTypeFace, shouldDisplayErrors: didTakePictureManually) else { return }
            if didTakePictureManually == false { // Rectangle detection on the side of a passport is iffy. If they're taking this manually, ought to just let it pass if the face is there.
                guard isImageValid(image, forDetectorType: CIDetectorTypeRectangle, shouldDisplayErrors: didTakePictureManually) else { return }
            }
        }
        
        guard let cgImage = CIContext().createCGImage(image, from: image.extent) else { // We have to do this to get a jpeg representation later
            print("Couldn't create cg image")
            if didTakePictureManually {
                displayError()
            }
            return
        }
        
        presentImage(UIImage(cgImage: cgImage))
    }
    
    @objc func acceptImage() {
        guard let image = currentImage else { return }
        imageAcceptanceView?.removeFromSuperview()
        imageAcceptanceView = nil
        var backImage: UIImage?
        
        switch scanType {
        case .frontLicense:
            frontImage = image
            scanType = .backLicense
            displayCaptureSession()
            return
        case .backLicense:
            backImage = image
        case .passport:
            frontImage = image
        }
        
        guard let frontImage = frontImage else {
            displayError()
            return
        }
        
        let scanResult = ScanResult(docType: scanType.docType, frontImage: frontImage, backImage: backImage, frontImageJpegDataString: frontImage.jpegData(compressionQuality: 0.92)?.base64EncodedString(options: .lineLength76Characters), backImageJpegDataString: backImage?.jpegData(compressionQuality: 0.92)?.base64EncodedString(options: .lineLength76Characters))
        delegate?.scanSucceeded(onScanViewController: self, scanResult: scanResult)
    }
    
    @objc func retryImage() {
        imageAcceptanceView?.removeFromSuperview()
        imageAcceptanceView = nil
        currentImage = nil
        
        displayCaptureSession()
    }
    
    // MARK: Delegate methods
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard shouldTakePicture else { return }
        switch scanType {
        case .frontLicense, .passport:
            guard metadataObjects.map({ $0.type }).contains(.face) else {
                hasPassedMetadataFilter = false
                return
            }
        case .backLicense:
            guard metadataObjects.map({ $0.type }).contains(.pdf417) else {
                hasPassedMetadataFilter = false
                return
            }
        }

        hasPassedMetadataFilter = true
    }

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let sampleBuffer = photoSampleBuffer,
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil),
            let image = CIImage(data: imageData) else {
                displayError()
                return
        }
        
        processImage(image, didTakePictureManually: true)
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard hasPassedMetadataFilter,
            shouldTakePicture,
            let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
        }
        shouldTakePicture = false
        restartTimer()
        
        processImage(CIImage(cvPixelBuffer: buffer, options: nil))
    }
}
