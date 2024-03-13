//
//  Generated code. Do not modify.
//  source: protos/protos.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'protos.pbenum.dart';

export 'protos.pbenum.dart';

/// protos/configuration.proto
class FlutterConfiguration extends $pb.GeneratedMessage {
  factory FlutterConfiguration({
    $core.Iterable<BarcodeFormat>? restrictFormat,
    $core.bool? flashInit,
  }) {
    final $result = create();
    if (restrictFormat != null) {
      $result.restrictFormat.addAll(restrictFormat);
    }
    if (flashInit != null) {
      $result.flashInit = flashInit;
    }
    return $result;
  }
  FlutterConfiguration._() : super();
  factory FlutterConfiguration.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FlutterConfiguration.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FlutterConfiguration', createEmptyInstance: create)
    ..pc<BarcodeFormat>(1, _omitFieldNames ? '' : 'restrictFormat', $pb.PbFieldType.KE, protoName: 'restrictFormat', valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values, defaultEnumValue: BarcodeFormat.unknown)
    ..aOB(2, _omitFieldNames ? '' : 'flashInit', protoName: 'flashInit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FlutterConfiguration clone() => FlutterConfiguration()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FlutterConfiguration copyWith(void Function(FlutterConfiguration) updates) => super.copyWith((message) => updates(message as FlutterConfiguration)) as FlutterConfiguration;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlutterConfiguration create() => FlutterConfiguration._();
  FlutterConfiguration createEmptyInstance() => create();
  static $pb.PbList<FlutterConfiguration> createRepeated() => $pb.PbList<FlutterConfiguration>();
  @$core.pragma('dart2js:noInline')
  static FlutterConfiguration getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FlutterConfiguration>(create);
  static FlutterConfiguration? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<BarcodeFormat> get restrictFormat => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get flashInit => $_getBF(1);
  @$pb.TagNumber(2)
  set flashInit($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFlashInit() => $_has(1);
  @$pb.TagNumber(2)
  void clearFlashInit() => clearField(2);
}

class ScanResult extends $pb.GeneratedMessage {
  factory ScanResult({
    ResultType? type,
    $core.String? rawContent,
    BarcodeFormat? format,
    $core.String? formatNote,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (rawContent != null) {
      $result.rawContent = rawContent;
    }
    if (format != null) {
      $result.format = format;
    }
    if (formatNote != null) {
      $result.formatNote = formatNote;
    }
    return $result;
  }
  ScanResult._() : super();
  factory ScanResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScanResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScanResult', createEmptyInstance: create)
    ..e<ResultType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ResultType.Barcode, valueOf: ResultType.valueOf, enumValues: ResultType.values)
    ..aOS(2, _omitFieldNames ? '' : 'rawContent', protoName: 'rawContent')
    ..e<BarcodeFormat>(3, _omitFieldNames ? '' : 'format', $pb.PbFieldType.OE, defaultOrMaker: BarcodeFormat.unknown, valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values)
    ..aOS(4, _omitFieldNames ? '' : 'formatNote', protoName: 'formatNote')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScanResult clone() => ScanResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScanResult copyWith(void Function(ScanResult) updates) => super.copyWith((message) => updates(message as ScanResult)) as ScanResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScanResult create() => ScanResult._();
  ScanResult createEmptyInstance() => create();
  static $pb.PbList<ScanResult> createRepeated() => $pb.PbList<ScanResult>();
  @$core.pragma('dart2js:noInline')
  static ScanResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScanResult>(create);
  static ScanResult? _defaultInstance;

  /// Represents the type of the result
  @$pb.TagNumber(1)
  ResultType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ResultType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  /// The barcode itself if the result type is barcode.
  /// If the result type is error it contains the error message
  @$pb.TagNumber(2)
  $core.String get rawContent => $_getSZ(1);
  @$pb.TagNumber(2)
  set rawContent($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRawContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawContent() => clearField(2);

  /// The barcode format
  @$pb.TagNumber(3)
  BarcodeFormat get format => $_getN(2);
  @$pb.TagNumber(3)
  set format(BarcodeFormat v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => clearField(3);

  /// If the format is unknown, this field holds additional information
  @$pb.TagNumber(4)
  $core.String get formatNote => $_getSZ(3);
  @$pb.TagNumber(4)
  set formatNote($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFormatNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormatNote() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
