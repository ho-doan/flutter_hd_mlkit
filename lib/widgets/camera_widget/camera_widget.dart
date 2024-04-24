import 'dart:async';
import 'dart:io';

import 'package:barcode_scan_custom/barcode_scan_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const List<BarcodeFormat> noQr = [
  BarcodeFormat.aztec,
  BarcodeFormat.code128,
  BarcodeFormat.code39,
  BarcodeFormat.code93,
  BarcodeFormat.dataMatrix,
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.interleaved2of5,
  BarcodeFormat.pdf417,
  BarcodeFormat.upce,
];

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
        return Stack(
          children: [
            if (Platform.isAndroid)
              AndroidView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams.writeToBuffer(),
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  widget.created(
                    CameraController(
                      channelFlutter: MethodChannel('camera_view/flutter_$id'),
                      channelNative: MethodChannel('camera_view/native_$id'),
                      flashInit: widget.flashInit,
                    ),
                  );
                },
              )
            else if (Platform.isIOS)
              UiKitView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams.writeToBuffer(),
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  widget.created(
                    CameraController(
                      channelFlutter: MethodChannel('camera_view/flutter_$id'),
                      channelNative: MethodChannel('camera_view/native_$id'),
                      flashInit: widget.flashInit,
                    ),
                  );
                },
              )
            else
              Center(
                child: Text(
                  'not support platform ${Platform.operatingSystem}!',
                ),
              ),
            if (Platform.isAndroid || Platform.isIOS)
              Positioned.fill(
                  child: _cameraOverlay(
                aspectRatio: size.width < size.height ? 3 / 2 : 6 / 4,
                color: Colors.black.withOpacity(.3),
                padding: size.width < size.height ? 60 : 30,
              ))
          ],
        );
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

abstract class CameraWidgetWrapper<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  CameraController? controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onPaused();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  void onResumed() {
    controller?.resumeCamera();
  }

  void onPaused() {
    controller?.pauseCamera();
  }

  void onInactive() {}
  void onDetached() {}
}
