import 'barcode_scan_custom_platform_interface.dart';
import 'model/model.dart';

export 'gen/protos/protos.pb.dart' show BarcodeFormat, ResultType;
export 'model/model.dart';

class BarcodeScanCustom {
  BarcodeScanCustom._();
  static final instance = BarcodeScanCustom._();

  Future<int> get numberOfCameras =>
      BarcodeScanCustomPlatform.instance.numberOfCameras;

  Future<String?> getPlatformVersion() {
    return BarcodeScanCustomPlatform.instance.getPlatformVersion();
  }

  Future<ScanResult> scan({
    ScanOptions options = const ScanOptions(),
  }) =>
      BarcodeScanCustomPlatform.instance.scan(options: options);
}
