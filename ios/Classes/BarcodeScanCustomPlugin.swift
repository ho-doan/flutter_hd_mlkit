import Flutter
import UIKit
import AVFoundation

public class BarcodeScanCustomPlugin: NSObject, FlutterPlugin {
    var sink:FlutterEventSink? = nil
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "barcode_scan_custom", binaryMessenger: registrar.messenger())
        
        let factory = CameraViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "camera_widget")
        
        let instance = BarcodeScanCustomPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermission":requestPer(result: result)
        case "cameraPermission": checkPer(result:result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func check()->Bool{
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        == AVAuthorizationStatus.authorized
    }
    
    private func checkPer(result : @escaping FlutterResult){
        result(check())
    }
    
    private func requestPer(result : @escaping FlutterResult){
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            (granted: Bool) -> Void in result(granted)
        })
    }
}
