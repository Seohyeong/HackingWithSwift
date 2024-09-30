//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Seohyeong Jeong on 8/25/24.
//

import AVFoundation // camera, video etc..
import UIKit


// pipeline: UIViewController -> Coordinator -> SwiftUI View

enum CameraError: String {
    case invalidDeviceInput     = "Something is wrong with the camera."
    case invalidScannedValue    = "The value scanned is invalid."
}

protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
    func didSurface(error: CameraError)
}

final class ScannerVC: UIViewController {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate?
    
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil) // needed for initializing viewcontroller
        self.scannerDelegate = scannerDelegate
    }
    
    // needed for initializing ScannerVC in storyboard
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // call setupCaptureSession() defined below
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    // set up preview layer
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // if don't have preview yet
        guard let previewLayer = previewLayer else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // set it to size we declared
        previewLayer.frame = view.layer.bounds
    }
    
    // setup for camera
    private func setupCaptureSession() {
        
        // check if there exists a device to capture video
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // input
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // output
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            // setting delegate
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // types of output the camera is looking for
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
        } else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // set up preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill // fill the view keeping aspect ratio (force unwrapping, just created previewLayer)
        view.layer.addSublayer(previewLayer!) // add preview layer to the view
        
        captureSession.startRunning()
    }
}


// to conform to the delegate (what to do once the output is found)
extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
     
        guard let object = metadataObjects.first else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        // pass the barcode to the delegate
        scannerDelegate?.didFind(barcode: barcode)
    }
}
