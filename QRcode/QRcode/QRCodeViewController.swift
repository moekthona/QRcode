//
//  QRCodeViewController.swift
//  QRcode
//
//  Created by Thona on 6/2/18.
//  Copyright © 2018 Thona. All rights reserved.
//

protocol ClassQRcodeDelegate: class {
    func getValueBack(value : String)
}

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController ,AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: ClassQRcodeDelegate?
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // var frameQRcode : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
    }
    
    
    func setup() {
        self.view.backgroundColor = UIColor.white
        
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "back"), for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        backbutton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 10);
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        self.navigationItem.title = "QRCode"
        
        let frameQRcode = UIImageView(frame: CGRect(x: 10, y:100 , width: 200, height: 200))
        frameQRcode.backgroundColor = UIColor.red
        
        self.view.addSubview(frameQRcode)
        self.view.bringSubview(toFront: frameQRcode)
        
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        
    }
    
    func found(code: String) {
        delegate?.getValueBack(value: code)
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc func buttonAction(sender: UIButton!){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
}
