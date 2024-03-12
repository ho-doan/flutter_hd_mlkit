package com.hodoan.barcode_scan_custom

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.PointF
import android.graphics.RectF
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata.CONTROL_AF_STATE_ACTIVE_SCAN
import android.hardware.camera2.CaptureRequest
import android.hardware.camera2.CaptureRequest.CONTROL_AF_MODE
import android.hardware.camera2.params.OutputConfiguration
import android.hardware.camera2.params.SessionConfiguration
import android.media.ImageReader
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.util.Size
import android.view.Surface
import android.view.TextureView
import android.view.View
import androidx.annotation.RequiresApi
import com.google.android.gms.common.util.concurrent.HandlerExecutor
import io.flutter.plugin.platform.PlatformView

@SuppressLint("RestrictedApi")
@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
internal class CameraView(context: Context, id: Int, creationParams: Map<String?, Any?>?) :
    PlatformView {
    private val textureView: TextureView
    private val cameraManager: CameraManager
    private val handlerThread: HandlerThread
    private val handle: Handler
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader
    private val context: Context

    private val listener: ImageReader.OnImageAvailableListener

    override fun getView(): View = textureView

    override fun dispose() = closeCamera()

    init {
        this.context = context
        textureView = TextureView(context)
        cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        handlerThread = HandlerThread("preview")
        handlerThread.start()
        handle = Handler(handlerThread.looper)

        listener = ImageReader.OnImageAvailableListener { p0 ->
            val image = p0?.acquireLatestImage()

            val rotation: Int = getDisplayRotation()

            val barcodeAnalyzer = BarcodeAnalyzer(context)
            barcodeAnalyzer.analyze(image, rotation)
            image?.close()
        }

        imageReader = ImageReader.newInstance(480, 640, ImageFormat.YUV_420_888, 2)
        imageReader.setOnImageAvailableListener(listener, handle)

        textureView.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(p0: SurfaceTexture, p1: Int, p2: Int) {
                openCamera()
            }

            override fun onSurfaceTextureSizeChanged(p0: SurfaceTexture, width: Int, height: Int) {
                setTextureTransform(cameraManager.getCameraCharacteristics(cameraManager.cameraIdList[0]))
            }

            override fun onSurfaceTextureDestroyed(p0: SurfaceTexture): Boolean {
                return false
            }

            override fun onSurfaceTextureUpdated(p0: SurfaceTexture) {

            }
        }
    }

    private fun closeCamera() {
        cameraDevice?.close()
        imageReader.close()
        cameraCaptureSession?.close()
        handle.removeCallbacksAndMessages(null)
        handlerThread.quitSafely()
        handlerThread.join()
    }

    private fun openCamera() = cameraManager.openCamera(cameraManager.cameraIdList[0], object :
        CameraDevice.StateCallback() {
        override fun onOpened(p0: CameraDevice) {
            cameraDevice = p0
            val capRed = cameraDevice?.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
            val surface = Surface(textureView.surfaceTexture)
            capRed?.addTarget(imageReader.surface)
            capRed?.addTarget(surface)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                cameraDevice?.createCaptureSession(
                    SessionConfiguration(
                        SessionConfiguration.SESSION_REGULAR,
                        listOf(
                            OutputConfiguration(imageReader.surface),
                            OutputConfiguration(surface),
                        ),
                        HandlerExecutor(handlerThread.looper),
                        object : CameraCaptureSession.StateCallback() {
                            override fun onConfigured(p0: CameraCaptureSession) {
                                configuredSession(p0, capRed)
                            }

                            override fun onConfigureFailed(p0: CameraCaptureSession) {}
                        }
                    ),
                )
            } else {
                @Suppress("DEPRECATION")
                cameraDevice?.createCaptureSession(
                    listOf(imageReader.surface, surface),
                    object : CameraCaptureSession.StateCallback() {
                        override fun onConfigured(p0: CameraCaptureSession) {
                            configuredSession(p0, capRed)
                        }

                        override fun onConfigureFailed(p0: CameraCaptureSession) {}
                    },
                    handle
                )
            }
        }

        override fun onDisconnected(p0: CameraDevice) {

        }

        override fun onError(p0: CameraDevice, p1: Int) {

        }
    }, handle)

    private fun configuredSession(p0: CameraCaptureSession, capRed: CaptureRequest.Builder?) {
        try {
            if (cameraDevice == null) return
            cameraCaptureSession = p0
            capRed?.set(CONTROL_AF_MODE, CONTROL_AF_STATE_ACTIVE_SCAN)
            capRed?.build()
                ?.let {
                    cameraCaptureSession?.setRepeatingRequest(it, null, null)
                }
        } catch (e: CameraAccessException) {
            Log.e(CameraView::class.simpleName, "onConfigured: $e")
        }
    }

    private fun getDisplayRotation(): Int {
        if (textureView.isAvailable)
            return when (textureView.display.rotation) {
                Surface.ROTATION_0 -> 0
                Surface.ROTATION_90 -> 90
                Surface.ROTATION_180 -> 180
                Surface.ROTATION_270 -> 270
                else -> 0
            }
        return 0
    }

    fun setTextureTransform(characteristics: CameraCharacteristics?) {
        val previewSize = getPreviewSize(characteristics!!)
        val width = previewSize.width
        val height = previewSize.height
        val sensorOrientation = getCameraSensorOrientation(characteristics)
        textureView.surfaceTexture!!.setDefaultBufferSize(width, height)
        val viewRect = RectF(0f, 0f, textureView.width.toFloat(), textureView.height.toFloat())
        var rotationDegrees = 0f
        try {
            rotationDegrees = getDisplayRotation().toFloat()
        } catch (ignored: Exception) {
        }
        val w: Float
        val h: Float
        if ((sensorOrientation - rotationDegrees) % 180 == 0f) {
            w = width.toFloat()
            h = height.toFloat()
        } else {
            w = height.toFloat()
            h = width.toFloat()
        }
        val viewAspectRatio = viewRect.width() / viewRect.height()
        val imageAspectRatio = w / h
        val scale: PointF = if (viewAspectRatio < imageAspectRatio) {
            PointF(viewRect.height() / viewRect.width() * (height.toFloat() / width.toFloat()), 1f)
        } else {
            PointF(1f, viewRect.width() / viewRect.height() * (width.toFloat() / height.toFloat()))
        }
        if (rotationDegrees % 180 != 0f) {
            val multiplier = if (viewAspectRatio < imageAspectRatio) w / h else h / w
            scale.x *= multiplier
            scale.y *= multiplier
        }
        val matrix = Matrix()
        matrix.setScale(scale.x, scale.y, viewRect.centerX(), viewRect.centerY())
        if (rotationDegrees != 0f) {
            matrix.postRotate(0 - rotationDegrees, viewRect.centerX(), viewRect.centerY())
        }
        textureView.setTransform(matrix)
    }

    private fun getPreviewSize(characteristics: CameraCharacteristics): Size {
        val map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
        val previewSizes: Array<Size> = map!!.getOutputSizes(SurfaceTexture::class.java)
        return previewSizes[0]
    }

    private fun getCameraSensorOrientation(characteristics: CameraCharacteristics): Int {
        val cameraOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION)
        return (360 - (cameraOrientation ?: 0)) % 360
    }
}

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class CView(context: Context) : TextureView(context) {
    private val cameraManager: CameraManager
    private val handlerThread: HandlerThread
    private val handle: Handler
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader
    private val context: Context

    private val listener: ImageReader.OnImageAvailableListener

    init {
        this.context = context
        cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        handlerThread = HandlerThread("preview")
        handlerThread.start()
        handle = Handler(handlerThread.looper)

        listener = ImageReader.OnImageAvailableListener { p0 ->
            val image = p0?.acquireLatestImage()

            val rotation: Int = getDisplayRotation()

            val barcodeAnalyzer = BarcodeAnalyzer(context)
            barcodeAnalyzer.analyze(image, rotation)
            image?.close()
        }

        imageReader = ImageReader.newInstance(480, 640, ImageFormat.YUV_420_888, 2)
        imageReader.setOnImageAvailableListener(listener, handle)

        surfaceTextureListener = object : SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(p0: SurfaceTexture, p1: Int, p2: Int) {
                openCamera()
            }

            override fun onSurfaceTextureSizeChanged(p0: SurfaceTexture, width: Int, height: Int) {
                setTextureTransform(cameraManager.getCameraCharacteristics(cameraManager.cameraIdList[0]))
            }

            override fun onSurfaceTextureDestroyed(p0: SurfaceTexture): Boolean {
                return false
            }

            override fun onSurfaceTextureUpdated(p0: SurfaceTexture) {

            }
        }
    }

    fun setTextureTransform(characteristics: CameraCharacteristics?) {
        val previewSize = getPreviewSize(characteristics!!)
        val width = previewSize.width
        val height = previewSize.height
        val sensorOrientation = getCameraSensorOrientation(characteristics)
        surfaceTexture!!.setDefaultBufferSize(width, height)
        val viewRect = RectF(0f, 0f, width.toFloat(), height.toFloat())
        var rotationDegrees = 0f
        try {
            rotationDegrees = getDisplayRotation().toFloat()
        } catch (ignored: Exception) {
        }
        val w: Float
        val h: Float
        if ((sensorOrientation - rotationDegrees) % 180 == 0f) {
            w = width.toFloat()
            h = height.toFloat()
        } else {
            w = height.toFloat()
            h = width.toFloat()
        }
        val viewAspectRatio = viewRect.width() / viewRect.height()
        val imageAspectRatio = w / h
        val scale: PointF = if (viewAspectRatio < imageAspectRatio) {
            PointF(viewRect.height() / viewRect.width() * (height.toFloat() / width.toFloat()), 1f)
        } else {
            PointF(1f, viewRect.width() / viewRect.height() * (width.toFloat() / height.toFloat()))
        }
        if (rotationDegrees % 180 != 0f) {
            val multiplier = if (viewAspectRatio < imageAspectRatio) w / h else h / w
            scale.x *= multiplier
            scale.y *= multiplier
        }
        val matrix = Matrix()
        matrix.setScale(scale.x, scale.y, viewRect.centerX(), viewRect.centerY())
        if (rotationDegrees != 0f) {
            matrix.postRotate(0 - rotationDegrees, viewRect.centerX(), viewRect.centerY())
        }
        setTransform(matrix)
    }
}