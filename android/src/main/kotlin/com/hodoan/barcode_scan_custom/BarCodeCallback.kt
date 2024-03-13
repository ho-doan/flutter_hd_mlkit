package com.hodoan.barcode_scan_custom

import com.hodoan.barcode_scan_custom.Protos.ScanResult

interface BarCodeCallback {
    fun barcodeResult(barcode: ScanResult)
}