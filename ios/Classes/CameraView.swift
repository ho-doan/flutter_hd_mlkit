//
//  CameraView.swift
//  barcode_scan_custom
//
//  Created by ominext on 13/03/2024.
//

import Foundation
import Flutter
import AVFoundation

@available(iOS 13.0, *)
class CameraView:NSObject,FlutterPlatformView{
    
    private var _view: UIView
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @available(iOS 13.0, *)
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification,object: nil)
        _createView()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self,name: UIDevice.orientationDidChangeNotification,object: nil)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        captureSession.stopRunning()
    }
    
    func view() -> UIView {
        return _view
    }
    
    private func configure() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    private func setupLivePreview(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
        _view.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                print("orientation \(self._view.bounds.width)")
                self.videoPreviewLayer.frame = self._view.bounds
            }
        }
    }
    
    private func _createView(){
        configure()
    }
    
    @objc private func rotated(){
        UIView.animate(withDuration: 4,delay: 4){
            print("orientation \(UIDevice.current.orientation.rawValue) \(self._view.bounds.width)")
            if UIDevice.current.orientation.isLandscape{
                DispatchQueue.main.async {
                    //                    self.videoPreviewLayer.videoGravity = .resizeAspectFill
                    if UIDevice.current.orientation == .landscapeLeft{
                        self.videoPreviewLayer.connection?.videoOrientation = .landscapeRight
                    }
                    if UIDevice.current.orientation == .landscapeRight{
                        self.videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
                    }
                    self.videoPreviewLayer.layoutIfNeeded()
                }
            }
            
            if UIDevice.current.orientation.isPortrait{
                DispatchQueue.main.async {
                    self.videoPreviewLayer.connection?.videoOrientation = .portrait
                }
            }
            self._view.setNeedsLayout()
            self.videoPreviewLayer.frame = self._view.bounds
            self.videoPreviewLayer.layoutIfNeeded()
        }
    }
}

class CustomView:UIView{
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func setNeedsDisplay() {
        
    }
}

@available(iOS 13.0, *)
class CameraViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return CameraView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
