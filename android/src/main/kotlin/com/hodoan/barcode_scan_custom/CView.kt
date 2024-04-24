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
import android.hardware.camera2.CameraMetadata
import android.hardware.camera2.CaptureRequest
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
import androidx.annotation.RequiresApi
import com.google.android.gms.common.util.concurrent.HandlerExecutor
import com.hodoan.barcode_scan_custom.Protos.FlutterConfiguration


@SuppressLint("ViewConstructor")
@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class CView(
    context: Context,
    private val callback: BarCodeCallback,
    private val config: FlutterConfiguration
) : TextureView(context) {
    private val cameraManager: CameraManager =
        context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private var handlerThread: HandlerThread? = null
    private var handle: Handler? = null
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader? = null

    private var capRed: CaptureRequest.Builder? = null

    private val listener: ImageReader.OnImageAvailableListener

    init {
        iniCamera()

        listener = ImageReader.OnImageAvailableListener { p0 ->
            val image = p0?.acquireLatestImage()

            val rotation: Int = getDisplayRotation()

            val barcodeAnalyzer = BarcodeAnalyzer(callback, config.restrictFormatList)
            barcodeAnalyzer.analyze(image, rotation)
            image?.close()
        }

        surfaceTextureListener = object : SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(p0: SurfaceTexture, p1: Int, p2: Int) {
                openCamera()
            }

            override fun onSurfaceTextureSizeChanged(p0: SurfaceTexture, width: Int, height: Int) {
                setTextureTransform(
                    cameraManager.getCameraCharacteristics(cameraManager.cameraIdList[0]),
                    width,
                    height
                )
            }

            override fun onSurfaceTextureDestroyed(p0: SurfaceTexture): Boolean {
                return false
            }

            override fun onSurfaceTextureUpdated(p0: SurfaceTexture) {

            }
        }
    }

    fun stopCamera() {
        handlerThread?.quitSafely()
        try {
            handlerThread?.join()
            handlerThread = null
            handle = null
        } catch (e: InterruptedException) {
            Log.e(CView::class.simpleName, "resumeCamera: ${e.stackTrace}")
        }
    }

    fun pauseCamera(){
        closeCamera()
        stopCamera()
    }

    fun iniCamera() {
        handlerThread = HandlerThread("CameraBackground").also { it.start() }
        handle = Handler(handlerThread!!.looper)
    }

    fun resumeCamera(){
        iniCamera()
        openCamera()
    }

    fun openCamera() {
        if (surfaceTexture == null) return
        cameraManager.openCamera(cameraManager.cameraIdList[0], object :
            CameraDevice.StateCallback() {
            override fun onOpened(p0: CameraDevice) {
                imageReader = ImageReader.newInstance(480, 640, ImageFormat.YUV_420_888, 2)
                imageReader!!.setOnImageAvailableListener(listener, handle)

                cameraDevice = p0
                capRed = cameraDevice?.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
                val surface = Surface(surfaceTexture)
                capRed?.addTarget(imageReader!!.surface)
                capRed?.addTarget(surface)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cameraDevice?.createCaptureSession(
                        SessionConfiguration(
                            SessionConfiguration.SESSION_REGULAR,
                            listOf(
                                OutputConfiguration(imageReader!!.surface),
                                OutputConfiguration(surface),
                            ),
                            HandlerExecutor(handlerThread!!.looper),
                            object : CameraCaptureSession.StateCallback() {
                                override fun onConfigured(p0: CameraCaptureSession) {
                                    configuredSession(p0)
                                }

                                override fun onConfigureFailed(p0: CameraCaptureSession) {}
                            }
                        ),
                    )
                } else {
                    @Suppress("DEPRECATION")
                    cameraDevice?.createCaptureSession(
                        listOf(imageReader!!.surface, surface),
                        object : CameraCaptureSession.StateCallback() {
                            override fun onConfigured(p0: CameraCaptureSession) {
                                configuredSession(p0)
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
    }

    fun closeCamera() {
        capRed = null
        cameraDevice?.close()
        imageReader?.close()
        cameraCaptureSession?.close()
        handle?.removeCallbacksAndMessages(null)
        handlerThread?.quitSafely()
        handlerThread?.join()
        handlerThread = null
        handle = null
    }

    fun flash(flash: Boolean) {
        capRed?.set(
            CaptureRequest.FLASH_MODE,
            if (flash) CameraMetadata.FLASH_MODE_TORCH else CameraMetadata.FLASH_MODE_OFF
        )
        capRed?.set(
            CaptureRequest.CONTROL_AE_MODE, CameraMetadata.CONTROL_AF_MODE_AUTO
        )
        capRed?.build()
            ?.let {
                cameraCaptureSession?.setRepeatingRequest(it, null, null)
            }
    }

    fun setTextureTransform(characteristics: CameraCharacteristics, mWidth: Int, mHeight: Int) {
        val previewSize = getPreviewSize(characteristics)
        val zWidth = previewSize.width
        val zHeight = previewSize.height
        val sensorOrientation = getCameraSensorOrientation(characteristics)
        // Indicate the size of the buffer the texture should expect
        surfaceTexture!!.setDefaultBufferSize(zWidth, zHeight)// width,height
        // Save the texture dimensions in a rectangle
        val viewRect = RectF(0f, 0f, mWidth.toFloat(), mHeight.toFloat())//
        // Determine the rotation of the display
        var rotationDegrees = 0f
        try {
            rotationDegrees = getDisplayRotation().toFloat()
        } catch (ignored: Exception) {
        }
        val w: Float
        val h: Float
        if ((sensorOrientation - rotationDegrees) % 180 == 0f) {
            w = zWidth.toFloat()
            h = zHeight.toFloat()
        } else {
            // Swap the width and height if the sensor orientation and display rotation don't match
            w = zHeight.toFloat()
            h = zWidth.toFloat()
        }
        val viewAspectRatio = viewRect.width() / viewRect.height()
        val imageAspectRatio = w / h
        // This will make the camera frame fill the texture view, if you'd like to fit it into the view swap the "<" sign for ">"
        val scale: PointF = if (viewAspectRatio < imageAspectRatio) {
            // If the view is "thinner" than the image constrain the height and calculate the scale for the texture width
            PointF(
                viewRect.height() / viewRect.width() * (zHeight.toFloat() / zWidth.toFloat()),
                1f
            )
        } else {
            PointF(
                1f,
                viewRect.width() / viewRect.height() * (zWidth.toFloat() / zHeight.toFloat())
            )
        }
        if (rotationDegrees % 180 != 0f) {
            // If we need to rotate the texture 90º we need to adjust the scale
            val multiplier = if (viewAspectRatio < imageAspectRatio) w / h else h / w
            scale.x *= multiplier
            scale.y *= multiplier
        }

        val matrix = Matrix()
        // Set the scale
        matrix.setScale(scale.x, scale.y, viewRect.centerX(), viewRect.centerY())
        if (rotationDegrees != 0f) {
            // Set rotation of the device isn't upright
            matrix.postRotate(0 - rotationDegrees, viewRect.centerX(), viewRect.centerY())
        }
        // Transform the texture
        setTransform(matrix)
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

    private fun getDisplayRotation(): Int {
        if (isAvailable)
            return when (display.rotation) {
                Surface.ROTATION_0 -> 0
                Surface.ROTATION_90 -> 90
                Surface.ROTATION_180 -> 180
                Surface.ROTATION_270 -> 270
                else -> 0
            }
        return 0
    }

    private fun configuredSession(p0: CameraCaptureSession) {
        try {
            if (cameraDevice == null) return
            cameraCaptureSession = p0
            if (config.flashInit) {
                capRed?.set(CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_TORCH)
                capRed?.set(CaptureRequest.CONTROL_AE_MODE, CameraMetadata.CONTROL_AF_MODE_AUTO)
            } else {
                capRed?.set(
                    CaptureRequest.CONTROL_AE_MODE, CameraMetadata.CONTROL_AF_STATE_ACTIVE_SCAN
                )
            }
            capRed?.build()
                ?.let {
                    cameraCaptureSession?.setRepeatingRequest(it, null, null)
                }
        } catch (e: CameraAccessException) {
            Log.e(CameraView::class.simpleName, "onConfigured: $e")
        }
    }
}