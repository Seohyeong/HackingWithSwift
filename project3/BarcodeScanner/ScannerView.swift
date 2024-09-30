//
//  ScannerView.swift
//  BarcodeScanner
//
//  Created by Seohyeong Jeong on 8/26/24.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    
    // bridging to the UI (BarcodeScannerView) & Coordinator
    @Binding var scannedCode: String
    
    // two func needed for UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> ScannerVC {
        // set up init
        ScannerVC(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {
    }
    
    // another func needed for Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self) // Coordinator is listening to ScannerVC
    }
    
    // coordinator is the delegate of the scannerVC
    final class Coordinator: NSObject, ScannerVCDelegate {
        
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didFind(barcode: String) {
            scannerView.scannedCode = barcode
        }
        
        func didSurface(error: CameraError) {
            print(error.rawValue)
        }
    }
}

#Preview {
    ScannerView(scannedCode: .constant("123456"))
}
