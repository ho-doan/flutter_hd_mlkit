//
//  CustomView.swift
//  barcode_scan_custom
//
//  Created by ominext on 15/03/2024.
//

import Foundation
import AVFoundation
import MLKitBarcodeScanning
import MLKitVision

protocol CustomViewDelegate{
    func barcode(_ result: ScanResult)
}

class CustomView: UIView{
    var delegate: CustomViewDelegate?
    
    var device: AVCaptureDevice!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var captureOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
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
        self.captureOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):kCVPixelFormatType_32BGRA]
        if self.captureSession.canAddOutput(self.captureOutput){
            self.captureOutput.alwaysDiscardsLateVideoFrames = true
            
            let outputQueue = DispatchQueue(label: "com.hodoan.barcode_scanner_custom.OutputQueue")
            self.captureOutput.setSampleBufferDelegate(self, queue: outputQueue)
            
            self.captureSession.addOutput(captureOutput)
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
    
    private func scanBarcodesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        // Define the options for a barcode detector.
        var format = MLKitBarcodeScanning.BarcodeFormat.all
        if config?.restrictFormat.count == 1{
            format = config!.restrictFormat.first!.mlBarcode()
        }
            
        let barcodeOptions = BarcodeScannerOptions(formats: format)
        
        // Create a barcode scanner.
        let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
        var barcodes: [Barcode] = []
        var scanningError: Error?
        do {
            barcodes = try barcodeScanner.results(in: image)
        } catch let error {
            scanningError = error
        }
        DispatchQueue.main.sync {
            if let scanningError = scanningError {
                print("Failed to scan barcodes with error: \(scanningError.localizedDescription).")
                return
            }
            guard !barcodes.isEmpty else {
                return
            }
            for barcode in barcodes {
                let result = ScanResult.with{
                    s in
                    s.rawContent = barcode.rawValue ?? ""
                    s.formatNote = barcode.displayValue ?? ""
                    s.type = ResultType.barcode
                    s.format = barcode.format.cn()
                }
                delegate?.barcode(result)
                print("\(String(describing: barcode.displayValue))")
            }
        }
    }
}

extension CustomView:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        
        let orientation:UIImage.Orientation = detectOrientation()
        visionImage.orientation = orientation
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        scanBarcodesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
    }
}
