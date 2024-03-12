package com.hodoan.barcode_scan_custom

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CameraViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return CameraView(context, viewId, creationParams)
    }
}