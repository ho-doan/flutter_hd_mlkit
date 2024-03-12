package com.hodoan.barcode_scan_custom

import android.content.Context
import android.media.Image
import android.os.Build
import android.widget.Toast
import androidx.annotation.RequiresApi
import com.google.mlkit.vision.barcode.Barcode
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage

class BarcodeAnalyzer(
    private val context: Context
) {
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun analyze(img: Image?, rotation: Int) {
        if (img != null) {

            val inputImage = InputImage.fromMediaImage(img, rotation)

            val options = BarcodeScannerOptions.Builder()
                .setBarcodeFormats(Barcode.FORMAT_ALL_FORMATS)
                .build()

            val scanner = BarcodeScanning.getClient(options)

            scanner.process(inputImage)
                .addOnSuccessListener { barcodes ->
                    if (barcodes.isNotEmpty()) {
                        for (barcode in barcodes) {
                            Toast.makeText(
                                context,
                                "Value: " + barcode.rawValue,
                                Toast.LENGTH_SHORT
                            )
                                .show()
                        }
                    }
                }
                .addOnFailureListener { }
        }

        img?.close()
    }
}