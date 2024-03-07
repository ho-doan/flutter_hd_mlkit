// import 'package:flutter_test/flutter_test.dart';
// import 'package:barcode_scan_custom/barcode_scan_custom.dart';
// import 'package:barcode_scan_custom/barcode_scan_custom_platform_interface.dart';
// import 'package:barcode_scan_custom/barcode_scan_custom_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockBarcodeScanCustomPlatform
//     with MockPlatformInterfaceMixin
//     implements BarcodeScanCustomPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final BarcodeScanCustomPlatform initialPlatform = BarcodeScanCustomPlatform.instance;

//   test('$MethodChannelBarcodeScanCustom is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelBarcodeScanCustom>());
//   });

//   test('getPlatformVersion', () async {
//     BarcodeScanCustom barcodeScanCustomPlugin = BarcodeScanCustom();
//     MockBarcodeScanCustomPlatform fakePlatform = MockBarcodeScanCustomPlatform();
//     BarcodeScanCustomPlatform.instance = fakePlatform;

//     expect(await barcodeScanCustomPlugin.getPlatformVersion(), '42');
//   });
// }
