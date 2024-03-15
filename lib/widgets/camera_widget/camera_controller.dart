import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/model.dart';

class CameraController {
  @visibleForTesting
  final MethodChannel channelFlutter;
  @visibleForTesting
  final MethodChannel channelNative;

  late ValueNotifier<bool> _flash;
  final ValueNotifier<List<ScanResult>> barcodeLst = ValueNotifier([]);

  CameraController({
    required this.channelFlutter,
    required this.channelNative,
    bool flashInit = false,
  }) {
    channelFlutter.setMethodCallHandler(_handle);
    _flash = ValueNotifier(flashInit);
  }

  Future<void> flash() async {
    _flash.value = !_flash.value;
    await channelNative.invokeMethod('flash', _flash.value);
  }

  Future<void> _handle(MethodCall call) async {
    switch (call.method) {
      case 'barcode':
        {
          final value = ScanResult.fromBuffer(call.arguments);
          final values = List<ScanResult>.from(barcodeLst.value)..add(value);
          barcodeLst.value = values;
        }
    }
  }
}
