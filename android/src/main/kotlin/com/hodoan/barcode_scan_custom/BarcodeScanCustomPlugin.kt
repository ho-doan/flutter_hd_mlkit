package com.hodoan.barcode_scan_custom

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** BarcodeScanCustomPlugin */
class BarcodeScanCustomPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel


    override fun onAttachedToEngine(flutterEngine: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterEngine.binaryMessenger,
            "barcode_scan_custom"
        )
        channel.setMethodCallHandler(this)
        flutterEngine
            .platformViewRegistry
            .registerViewFactory("camera_widget", CameraViewFactory())

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success(1)
            "numberOfCameras" -> result.success(1)
            "scan" -> result.success(null)
        }
    }
}
