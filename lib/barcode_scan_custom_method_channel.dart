import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'gen/protos/protos.pb.dart' as proto;

import 'barcode_scan_custom_platform_interface.dart';
import 'model/model.dart';

/// An implementation of [BarcodeScanCustomPlatform] that uses method channels.
class MethodChannelBarcodeScanCustom extends BarcodeScanCustomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final channel = const MethodChannel('barcode_scan_custom');

  @visibleForTesting
  static const EventChannel event = EventChannel('barcode_scan_custom/events');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int> get numberOfCameras async =>
      (await channel.invokeMethod<int>('numberOfCameras'))!;

  @override
  Future<ScanResult> scan({ScanOptions options = const ScanOptions()}) async {
    if (Platform.isIOS) {
      return _doScan(options);
    }

    final events = event.receiveBroadcastStream();
    final completer = Completer<ScanResult>();

    late StreamSubscription<dynamic> subscription;
    subscription = events.listen((dynamic event) async {
      if (event is String) {
        if (event == cameraAccessGranted) {
          // ignore: unawaited_futures
          subscription.cancel();
          completer.complete(await _doScan(options));
        } else if (event == cameraAccessDenied) {
          // ignore: unawaited_futures
          subscription.cancel();
          completer.completeError(PlatformException(code: event));
        }
      }
    });

    final permissionsRequested =
        (await channel.invokeMethod<bool>('requestCameraPermission'))!;

    if (permissionsRequested) {
      return completer.future;
    } else {
      await subscription.cancel();
      return _doScan(options);
    }
  }

  Future<ScanResult> _doScan(ScanOptions options) async {
    final config = proto.Configuration()
      ..useCamera = options.useCamera
      ..restrictFormat.addAll(options.restrictFormat)
      ..autoEnableFlash = options.autoEnableFlash
      ..strings.addAll(options.strings)
      ..android = (proto.AndroidConfiguration()
        ..useAutoFocus = options.android.useAutoFocus
        ..aspectTolerance = options.android.aspectTolerance);
    final buffer = (await channel.invokeMethod<List<int>>(
      'scan',
      config.writeToBuffer(),
    ))!;
    final tmpResult = proto.ScanResult.fromBuffer(buffer);
    return ScanResult(
      format: tmpResult.format,
      formatNote: tmpResult.formatNote,
      rawContent: tmpResult.rawContent,
      type: tmpResult.type,
    );
  }
}
