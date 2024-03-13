import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barcode_scan_custom_platform_interface.dart';

/// An implementation of [BarcodeScanCustomPlatform] that uses method channels.
class MethodChannelBarcodeScanCustom extends BarcodeScanCustomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final channel = const MethodChannel('barcode_scan_custom');

  @visibleForTesting
  static const EventChannel event = EventChannel('barcode_scan_custom/events');

  @override
  Future<bool> requestPermission() async {
    final completer = Completer<bool>();
    late StreamSubscription? stream;
    if (Platform.isAndroid) {
      stream = event.receiveBroadcastStream().listen((event) {
        if (event is bool) {
          completer.complete(event);
          stream?.cancel();
        }
      });
    }
    final version =
        await channel.invokeMethod<bool?>('requestPermission') ?? false;
    if (Platform.isIOS || version) {
      stream?.cancel();
      return version;
    }
    return completer.future;
  }

  @override
  Future<bool> get cameraPermission async =>
      (await channel.invokeMethod<bool>('cameraPermission')) ?? false;
}
