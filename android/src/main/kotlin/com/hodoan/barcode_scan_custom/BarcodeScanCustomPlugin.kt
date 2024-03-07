package com.hodoan.barcode_scan_custom

import androidx.annotation.NonNull
import androidx.annotation.Nullable

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** BarcodeScanCustomPlugin */
class BarcodeScanCustomPlugin : FlutterPlugin, ActivityAware {

    @Nullable
    private var channelHandler: ChannelHandler? = null

    @Nullable
    private var activityHelper: ActivityHelper? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channelHandler = ChannelHandler(activityHelper!!)
        channelHandler!!.startListening(flutterPluginBinding.binaryMessenger)
    }

    companion object {
        @Suppress("unused")
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val handler = ChannelHandler(
                ActivityHelper(
                    registrar.context(),
                    registrar.activity()
                )
            )
            handler.startListening(registrar.messenger())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (channelHandler == null) {
            return
        }

        channelHandler!!.stopListening()
        channelHandler = null
        activityHelper = null
    }

    override fun onDetachedFromActivity() {
        if (channelHandler == null) {
            return
        }

        activityHelper!!.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (channelHandler == null) {
            return
        }
        binding.addActivityResultListener(activityHelper!!)
        binding.addRequestPermissionsResultListener(activityHelper!!)
        activityHelper!!.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}
