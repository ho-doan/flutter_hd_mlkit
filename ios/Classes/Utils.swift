//
//  Utils.swift
//  barcode_scan_custom
//
//  Created by ominext on 15/03/2024.
//

import Foundation
import Flutter
import MLKitBarcodeScanning

extension Any?{
    func parserData()->Data{
        let flutterData = self as! FlutterStandardTypedData
        return Data(flutterData.data)
    }
}

extension BarcodeFormat{
    func mlBarcode()->MLKitBarcodeScanning.BarcodeFormat{
        switch self{
        case .unknown:
            .all
        case .aztec:
            .aztec
        case .code39:
            .code39
        case .code93:
            .code93
        case .ean8:
            .EAN8
        case .ean13:
            .EAN13
        case .code128:
            .code128
        case .dataMatrix:
            .dataMatrix
        case .qr:
            .qrCode
        case .interleaved2Of5:
            .ITF
        case .upce:
            .UPCE
        case .pdf417:
            .PDF417
        case .all:
            .all
        case .UNRECOGNIZED(_):
            .all
        }
    }
}

extension MLKitBarcodeScanning.BarcodeFormat{
    func cn()->BarcodeFormat{
        switch self{
        case .aztec:return .aztec
        case .code39: return .code39
        case .code93: return .code93
        case .EAN8: return .ean8
        case .EAN13: return .ean13
        case .code128: return .code128
        case .dataMatrix: return .dataMatrix
        case .qrCode: return .qr
        case .ITF: return .interleaved2Of5
        case .UPCA: return .upce
        case .UPCE: return .upce
        case .PDF417: return .pdf417
        default:
            return .unknown
        }
    }
}
