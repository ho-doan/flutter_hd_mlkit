import 'dart:async';
import 'dart:io';

import 'package:barcode_scan_custom/barcode_scan_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraController {
  @visibleForTesting
  final MethodChannel channelFlutter;
  @visibleForTesting
  final MethodChannel channelNative;

  late ValueNotifier<bool> _flash;
  final ValueNotifier<List<ScanResult>> barcodeLst = ValueNotifier([]);

  CameraController._({
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

class CameraWidget extends StatefulWidget {
  const CameraWidget({
    super.key,
    required this.created,
    this.flashInit = false,
    this.formats = const [BarcodeFormat.all],
  });

  final ValueChanged<CameraController> created;
  final bool flashInit;
  final List<BarcodeFormat> formats;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  final String viewType = 'camera_widget';
  late FlutterConfiguration creationParams;

  final _permission = ValueNotifier(false);

  @override
  void initState() {
    creationParams = FlutterConfiguration(
      restrictFormat: widget.formats,
      flashInit: widget.flashInit,
    );
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ValueListenableBuilder(
      valueListenable: _permission,
      builder: (_, value, __) {
        if (!value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (Platform.isAndroid) {
          return Stack(
            children: [
              AndroidView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams.writeToBuffer(),
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  widget.created(
                    CameraController._(
                      channelFlutter: MethodChannel('camera_view/flutter_$id'),
                      channelNative: MethodChannel('camera_view/native_$id'),
                      flashInit: widget.flashInit,
                    ),
                  );
                },
              ),
              Positioned.fill(
                  child: _cameraOverlay(
                aspectRatio: size.width < size.height ? 3 / 2 : 6 / 4,
                color: Colors.black.withOpacity(.3),
                padding: size.width < size.height ? 60 : 30,
              ))
            ],
          );
        }
        return Container();
      },
    );
  }

  Future<void> _init() async {
    final value = await BarcodeScanCustom.instance.cameraPermission;
    _permission.value = value;
    if (!value) {
      final result = await BarcodeScanCustom.instance.requestPermission();
      _permission.value = result;
    }
  }
}

Widget _cameraOverlay({
  required double padding,
  required double aspectRatio,
  required Color color,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
      double horizontalPadding;
      double verticalPadding;

      if (parentAspectRatio < aspectRatio) {
        horizontalPadding = padding;
        verticalPadding = (constraints.maxHeight -
                ((constraints.maxWidth - 2 * padding) / aspectRatio)) /
            2;
      } else {
        verticalPadding = padding;
        horizontalPadding = (constraints.maxWidth -
                ((constraints.maxHeight - 2 * padding) * aspectRatio)) /
            2;
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(width: horizontalPadding, color: color),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(width: horizontalPadding, color: color),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              height: verticalPadding,
              color: color,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              height: verticalPadding,
              color: color,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyan),
            ),
          )
        ],
      );
    },
  );
}
