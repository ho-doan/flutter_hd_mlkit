package com.hodoan.barcode_scan_custom

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CameraViewFactory(binaryMessenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var binaryMessenger: BinaryMessenger

    init {
        this.binaryMessenger = binaryMessenger
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return CameraView(binaryMessenger, context, viewId, args)
    }
}