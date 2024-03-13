package com.hodoan.barcode_scan_custom

import android.media.Image
import android.os.Build
import androidx.annotation.RequiresApi
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.hodoan.barcode_scan_custom.Protos as proto

class BarcodeAnalyzer(
    private val callback: BarCodeCallback,
    private val formats: List<proto.BarcodeFormat>
) {


    private fun getFormat(barcode: proto.BarcodeFormat) = when (barcode) {
        proto.BarcodeFormat.code128 -> Barcode.FORMAT_CODE_128
        proto.BarcodeFormat.code39 -> Barcode.FORMAT_CODE_39
        proto.BarcodeFormat.code93 -> Barcode.FORMAT_CODE_93
        proto.BarcodeFormat.dataMatrix -> Barcode.FORMAT_DATA_MATRIX
        proto.BarcodeFormat.ean8 -> Barcode.FORMAT_EAN_8
        proto.BarcodeFormat.interleaved2of5 -> Barcode.FORMAT_ITF
        proto.BarcodeFormat.ean13 -> Barcode.FORMAT_EAN_13
        proto.BarcodeFormat.qr -> Barcode.FORMAT_QR_CODE
        proto.BarcodeFormat.upce -> Barcode.FORMAT_UPC_A
        proto.BarcodeFormat.pdf417 -> Barcode.FORMAT_PDF417
        proto.BarcodeFormat.aztec -> Barcode.FORMAT_AZTEC
//        proto.BarcodeFormat.upce->Barcode.FORMAT_UPC_E
//        Barcode.FORMAT_CODABAR -> proto.BarcodeFormat.unknown
        else -> Barcode.FORMAT_ALL_FORMATS
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun analyze(img: Image?, rotation: Int) {
        if (img != null) {

            val inputImage = InputImage.fromMediaImage(img, rotation)

            val lst: List<Int> = formats.map { getFormat(it) }

            val check = lst.any { it == Barcode.FORMAT_ALL_FORMATS }

            val first = if (check) Barcode.FORMAT_ALL_FORMATS else lst.first()

            val last = if (!check) lst.toIntArray() else intArrayOf()

            val options = BarcodeScannerOptions.Builder()
                .setBarcodeFormats(first, *last)
                .build()

            val scanner = BarcodeScanning.getClient(options)

            scanner.process(inputImage)
                .addOnSuccessListener { barcodes ->
                    if (barcodes.isNotEmpty()) {
                        for (barcode in barcodes) {
                            val format = when (barcode.format) {
                                Barcode.FORMAT_UNKNOWN -> proto.BarcodeFormat.unknown
                                Barcode.FORMAT_CODE_128 -> proto.BarcodeFormat.code128
                                Barcode.FORMAT_CODE_39 -> proto.BarcodeFormat.code39
                                Barcode.FORMAT_CODE_93 -> proto.BarcodeFormat.code93
                                // TODO hodoan
                                Barcode.FORMAT_CODABAR -> proto.BarcodeFormat.unknown
                                Barcode.FORMAT_DATA_MATRIX -> proto.BarcodeFormat.dataMatrix
                                Barcode.FORMAT_EAN_13 -> proto.BarcodeFormat.ean13
                                Barcode.FORMAT_EAN_8 -> proto.BarcodeFormat.ean8
                                Barcode.FORMAT_ITF -> proto.BarcodeFormat.interleaved2of5
                                Barcode.FORMAT_QR_CODE -> proto.BarcodeFormat.qr
                                Barcode.FORMAT_UPC_A -> proto.BarcodeFormat.upce
                                Barcode.FORMAT_UPC_E -> proto.BarcodeFormat.upce
                                Barcode.FORMAT_PDF417 -> proto.BarcodeFormat.pdf417
                                Barcode.FORMAT_AZTEC -> proto.BarcodeFormat.aztec
                                else -> proto.BarcodeFormat.unknown
                            }
                            val result = proto.ScanResult.newBuilder()
                                .setFormat(format)
                                .setType(proto.ResultType.Barcode)
                                .setRawContent(barcode.rawValue)
                                .setFormatNote(barcode.displayValue)
                                .build()
                            callback.barcodeResult(result)
                        }
                    }
                }
                .addOnFailureListener { }
        }
        img?.close()
    }
}