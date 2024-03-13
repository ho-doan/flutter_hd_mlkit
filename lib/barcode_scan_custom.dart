import 'barcode_scan_custom_platform_interface.dart';

export 'model/model.dart';
export 'widgets/camera_widget/camera_widget.dart';
export 'widgets/camera_widget/camera_controller.dart';

class BarcodeScanCustom {
  BarcodeScanCustom._();
  static final instance = BarcodeScanCustom._();

  Future<bool> requestPermission() {
    return BarcodeScanCustomPlatform.instance.requestPermission();
  }

  Future<bool> get cameraPermission =>
      BarcodeScanCustomPlatform.instance.cameraPermission;
}
