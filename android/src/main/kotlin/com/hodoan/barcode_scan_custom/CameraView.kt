package com.hodoan.barcode_scan_custom

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.view.View
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

@SuppressLint("RestrictedApi")
@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
internal class CameraView(
    binaryMessenger: BinaryMessenger,
    context: Context,
    id: Int,
    creationParams: Any?
) :
    PlatformView, MethodChannel.MethodCallHandler, BarCodeCallback {
    private val cView: CView
    private val channelFlutter: MethodChannel
    private val channelNative: MethodChannel

    override fun getView(): View = cView

    override fun dispose() = cView.closeCamera()

    override fun onFlutterViewAttached(flutterView: View) {
        cView.openCamera()
        super.onFlutterViewAttached(flutterView)
    }

    init {
        channelFlutter = MethodChannel(binaryMessenger, "camera_view/flutter_$id")
        channelNative = MethodChannel(binaryMessenger, "camera_view/native_$id")
        channelNative.setMethodCallHandler(this)

        val c = Protos.FlutterConfiguration.parseFrom(creationParams as ByteArray)
//
//        val formats: List<Int> = creationParams?.get("formats") as List<Int>? ?: listOf()

        cView = CView(context, this, c)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "flash" -> result.success(cView.flash(call.arguments as Boolean))
            else -> result.notImplemented()
        }
    }

    override fun barcodeResult(barcode: Protos.ScanResult) {
        channelFlutter.invokeMethod("barcode", barcode.toByteArray())
    }
}