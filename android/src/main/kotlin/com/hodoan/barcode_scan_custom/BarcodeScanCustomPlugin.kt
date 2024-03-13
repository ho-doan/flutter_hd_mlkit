package com.hodoan.barcode_scan_custom

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** BarcodeScanCustomPlugin */
class BarcodeScanCustomPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
    PluginRegistry.RequestPermissionsResultListener, EventChannel.StreamHandler {

    private lateinit var channel: MethodChannel
    private lateinit var event: EventChannel
    private var sink: EventSink? = null
    private var activity: Activity? = null


    override fun onAttachedToEngine(flutterEngine: FlutterPlugin.FlutterPluginBinding) {

        event = EventChannel(flutterEngine.binaryMessenger, "barcode_scan_custom/events")
        event.setStreamHandler(this)
        channel = MethodChannel(
            flutterEngine.binaryMessenger,
            "barcode_scan_custom"
        )
        channel.setMethodCallHandler(this)
        flutterEngine
            .platformViewRegistry
            .registerViewFactory("camera_widget", CameraViewFactory(flutterEngine.binaryMessenger))

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermission" -> {
                if (activity == null) {
                    result.success(false)
                }
                val check = ContextCompat.checkSelfPermission(
                    activity!!,
                    Manifest.permission.CAMERA
                ) == PackageManager.PERMISSION_GRANTED
                if (check) result.success(true)

                val array = arrayOf(Manifest.permission.CAMERA)
                result.success(false)
                ActivityCompat.requestPermissions(activity!!, array, 200)
            }

            "cameraPermission" -> {
                if (activity == null) {
                    result.success(false)
                }
                val check = ContextCompat.checkSelfPermission(
                    activity!!,
                    Manifest.permission.CAMERA
                ) == PackageManager.PERMISSION_GRANTED
                result.success(check)
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        sink?.success(requestCode == 200)
        return true
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}
