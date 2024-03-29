// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: protos/protos.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// AUTO GENERATED FILE, DO NOT EDIT!
//
// Generated by ./generate_proto.sh

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// protos/barcode_format.proto
enum BarcodeFormat: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unknown // = 0
  case aztec // = 1
  case code39 // = 2
  case code93 // = 3
  case ean8 // = 4
  case ean13 // = 5
  case code128 // = 6
  case dataMatrix // = 7
  case qr // = 8
  case interleaved2Of5 // = 9
  case upce // = 10
  case pdf417 // = 11

  /// only settings
  case all // = 12
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .aztec
    case 2: self = .code39
    case 3: self = .code93
    case 4: self = .ean8
    case 5: self = .ean13
    case 6: self = .code128
    case 7: self = .dataMatrix
    case 8: self = .qr
    case 9: self = .interleaved2Of5
    case 10: self = .upce
    case 11: self = .pdf417
    case 12: self = .all
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .aztec: return 1
    case .code39: return 2
    case .code93: return 3
    case .ean8: return 4
    case .ean13: return 5
    case .code128: return 6
    case .dataMatrix: return 7
    case .qr: return 8
    case .interleaved2Of5: return 9
    case .upce: return 10
    case .pdf417: return 11
    case .all: return 12
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension BarcodeFormat: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [BarcodeFormat] = [
    .unknown,
    .aztec,
    .code39,
    .code93,
    .ean8,
    .ean13,
    .code128,
    .dataMatrix,
    .qr,
    .interleaved2Of5,
    .upce,
    .pdf417,
    .all,
  ]
}

#endif  // swift(>=4.2)

/// protos/scan_result.proto
enum ResultType: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case barcode // = 0
  case cancelled // = 1
  case error // = 2
  case UNRECOGNIZED(Int)

  init() {
    self = .barcode
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .barcode
    case 1: self = .cancelled
    case 2: self = .error
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .barcode: return 0
    case .cancelled: return 1
    case .error: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ResultType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [ResultType] = [
    .barcode,
    .cancelled,
    .error,
  ]
}

#endif  // swift(>=4.2)

/// protos/configuration.proto
struct FlutterConfiguration {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var restrictFormat: [BarcodeFormat] = []

  var flashInit: Bool = false

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct ScanResult {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Represents the type of the result
  var type: ResultType = .barcode

  /// The barcode itself if the result type is barcode.
  /// If the result type is error it contains the error message
  var rawContent: String = String()

  /// The barcode format
  var format: BarcodeFormat = .unknown

  /// If the format is unknown, this field holds additional information
  var formatNote: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension BarcodeFormat: @unchecked Sendable {}
extension ResultType: @unchecked Sendable {}
extension FlutterConfiguration: @unchecked Sendable {}
extension ScanResult: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension BarcodeFormat: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "unknown"),
    1: .same(proto: "aztec"),
    2: .same(proto: "code39"),
    3: .same(proto: "code93"),
    4: .same(proto: "ean8"),
    5: .same(proto: "ean13"),
    6: .same(proto: "code128"),
    7: .same(proto: "dataMatrix"),
    8: .same(proto: "qr"),
    9: .same(proto: "interleaved2of5"),
    10: .same(proto: "upce"),
    11: .same(proto: "pdf417"),
    12: .same(proto: "all"),
  ]
}

extension ResultType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Barcode"),
    1: .same(proto: "Cancelled"),
    2: .same(proto: "Error"),
  ]
}

extension FlutterConfiguration: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FlutterConfiguration"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "restrictFormat"),
    2: .same(proto: "flashInit"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedEnumField(value: &self.restrictFormat) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self.flashInit) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.restrictFormat.isEmpty {
      try visitor.visitPackedEnumField(value: self.restrictFormat, fieldNumber: 1)
    }
    if self.flashInit != false {
      try visitor.visitSingularBoolField(value: self.flashInit, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FlutterConfiguration, rhs: FlutterConfiguration) -> Bool {
    if lhs.restrictFormat != rhs.restrictFormat {return false}
    if lhs.flashInit != rhs.flashInit {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ScanResult: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "ScanResult"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "rawContent"),
    3: .same(proto: "format"),
    4: .same(proto: "formatNote"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.type) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.rawContent) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.format) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.formatNote) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.type != .barcode {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 1)
    }
    if !self.rawContent.isEmpty {
      try visitor.visitSingularStringField(value: self.rawContent, fieldNumber: 2)
    }
    if self.format != .unknown {
      try visitor.visitSingularEnumField(value: self.format, fieldNumber: 3)
    }
    if !self.formatNote.isEmpty {
      try visitor.visitSingularStringField(value: self.formatNote, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: ScanResult, rhs: ScanResult) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.rawContent != rhs.rawContent {return false}
    if lhs.format != rhs.format {return false}
    if lhs.formatNote != rhs.formatNote {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
