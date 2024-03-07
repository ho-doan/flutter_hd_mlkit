import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barcode_scan_custom_method_channel.dart';
import 'model/model.dart';

abstract class BarcodeScanCustomPlatform extends PlatformInterface {
  /// Constructs a BarcodeScanCustomPlatform.
  BarcodeScanCustomPlatform() : super(token: _token);

  static final Object _token = Object();

  static BarcodeScanCustomPlatform _instance = MethodChannelBarcodeScanCustom();

  /// The default instance of [BarcodeScanCustomPlatform] to use.
  ///
  /// Defaults to [MethodChannelBarcodeScanCustom].
  static BarcodeScanCustomPlatform get instance => _instance;

  Future<int> get numberOfCameras {
    throw UnimplementedError('numberOfCameras() has not been implemented.');
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BarcodeScanCustomPlatform] when
  /// they register themselves.
  static set instance(BarcodeScanCustomPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<ScanResult> scan({
    ScanOptions options = const ScanOptions(),
  }) {
    throw UnimplementedError('scan() has not been implemented.');
  }
}
