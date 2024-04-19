//
//  Utils.swift
//  barcode_scan_custom
//
//  Created by ominext on 15/03/2024.
//

import Foundation
import Flutter
import AVFoundation

extension Any?{
    func parserData()->Data{
        let flutterData = self as! FlutterStandardTypedData
        return Data(flutterData.data)
    }
}

extension BarcodeFormat{
    func abarcode()->AVMetadataObject.ObjectType{
        switch self{
        case .unknown:
            .qr
        case .aztec:
            .aztec
        case .code39:
            .code39
        case .code93:
            .code93
        case .ean8:
            .ean8
        case .ean13:
            .ean13
        case .code128:
            .code128
        case .dataMatrix:
            .dataMatrix
        case .qr:
            .qr
        case .interleaved2Of5:
            .interleaved2of5
        case .upce:
            .upce
        case .pdf417:
            .pdf417
        case .all:
            .qr
        case .UNRECOGNIZED(_):
            .qr
        }
    }
}

extension AVMetadataObject.ObjectType{
    func cn()->BarcodeFormat{
        switch self{
        case .aztec:return .aztec
        case .code39: return .code39
        case .code93: return .code93
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .code128: return .code128
        case .dataMatrix: return .dataMatrix
        case .qr: return .qr
        case .interleaved2of5: return .interleaved2Of5
        case .upce: return .upce
        case .pdf417: return .pdf417
        default:
            return .unknown
        }
    }
}
