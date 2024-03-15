//
//  CameraView.swift
//  barcode_scan_custom
//
//  Created by ominext on 13/03/2024.
//

import Foundation
import Flutter

class CameraView:NSObject,FlutterPlatformView{
    
    private var _view: CustomView
    
    private var channelFlutter: FlutterMethodChannel!
    private var channelNative: FlutterMethodChannel!
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let config = try? FlutterConfiguration(serializedData: args.parserData())
        
        _view = CustomView(frame: frame, config)
        
        channelFlutter = FlutterMethodChannel(name: "camera_view/flutter_\(viewId)", binaryMessenger: messenger)
        channelNative = FlutterMethodChannel(name: "camera_view/native_\(viewId)", binaryMessenger: messenger)
        
        super.init()
        
        _view.delegate = self
        channelNative.setMethodCallHandler(handle)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "flash":
            _view.flash(call.arguments as! Bool)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension CameraView: CustomViewDelegate{
    func barcode(_ result: ScanResult) {
        let data = try? result.serializedData()
        channelFlutter.invokeMethod("barcode", arguments: data)
    }
}
