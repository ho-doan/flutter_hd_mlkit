//
//  CustomView.swift
//  barcode_scan_custom
//
//  Created by ominext on 15/03/2024.
//

import Foundation
import AVFoundation

protocol CustomViewDelegate{
    func barcode(_ result: ScanResult)
}

class CustomView: UIView{
    var delegate: CustomViewDelegate?
    
    var device: AVCaptureDevice!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var outputMeta = AVCaptureMetadataOutput()
    
    var currentFrame: CGRect!
    
    var config: FlutterConfiguration? = nil
    
    init(frame: CGRect, _ config: FlutterConfiguration?) {
        super.init(frame: frame)
        self.config = config
        _configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        _configure()
    }
    
    deinit{
        captureSession.stopRunning()
    }
    
    override func layoutSubviews() {
        if currentFrame == nil{
            currentFrame = self.frame
            return
        }
        if currentFrame == self.frame{
            return
        }
        currentFrame = self.frame
        updateSubView()
    }
    
    func setCameraOrientation(){
        if UIDevice.current.orientation.isLandscape{
            DispatchQueue.main.async {
                if UIDevice.current.orientation == .landscapeLeft{
                    self.videoPreviewLayer.connection?.videoOrientation = .landscapeRight
                }
                if UIDevice.current.orientation == .landscapeRight{
                    self.videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
                }
            }
        }
        
        if UIDevice.current.orientation.isPortrait{
            DispatchQueue.main.async {
                self.videoPreviewLayer.connection?.videoOrientation = .portrait
            }
        }
        self.videoPreviewLayer.frame = self.bounds
    }
    
    func updateSubView(){
        setCameraOrientation()
        self.videoPreviewLayer.layoutIfNeeded()
    }
    
    func flash(_ flash: Bool){
        do {
            if device.hasTorch{
                try device.lockForConfiguration()
                if flash{
                    device.torchMode = .on
                }else{
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            }
        } catch {
            print("flash error: \(error.localizedDescription)")
        }
    }
    
    func _configure() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            device = backCamera
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupOutput()
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    private func setupOutput(){
        if self.captureSession.canAddOutput(self.outputMeta){
            self.captureSession.addOutput(self.outputMeta)
            self.outputMeta.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            var format:[AVMetadataObject.ObjectType] = [.aztec,.code39,.code93,.ean8,.ean13,.code128,.dataMatrix,.qr,.interleaved2of5,.upce,.pdf417]
            if config?.restrictFormat.count == 1{
                let first = config!.restrictFormat.first
                if first != .all || first != .unknown {
                    format = [config!.restrictFormat.first!.abarcode()]
                }
            }else {
                let cnt = config?.restrictFormat.isEmpty ?? true
                if !cnt{
                    let check = config?.restrictFormat.contains(.all) ?? true
                    if !check{
                        format = config!.restrictFormat.map({$0.abarcode()})
                    }
                }
            }
            self.outputMeta.metadataObjectTypes = format
        }
    }
    
    private func setupLivePreview(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        setCameraOrientation()
        self.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.bounds
            }
        }
        
        if let flashInit = config?.flashInit{
            if flashInit{
                flash(true)
            }
        }
    }
    
    func detectOrientation()->UIImage.Orientation{
        switch UIDevice.current.orientation{
        case .portrait: return .right
        case .landscapeLeft:return .up
        case .landscapeRight:return .down
        case .portraitUpsideDown: return .left
        case .unknown, .faceUp,.faceDown:
            return .up
        @unknown default:
            return .up
        }
    }
    
    func scanResult(result: ScanResult){
        delegate?.barcode(result)
    }
    
}

extension CustomView:AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0{
            print("none code")
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if metadataObj.stringValue != nil {
                let result = ScanResult.with{
                    s in
                    s.rawContent = metadataObj.stringValue ?? ""
                    s.formatNote = metadataObj.accessibilityValue ?? ""
                    s.type = ResultType.barcode
                    s.format = metadataObj.type.cn()
                }
                scanResult(result: result)
            }
        }
    }
}
