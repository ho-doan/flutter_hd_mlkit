import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  final String viewType = 'camera_widget';
  final Map<String, dynamic> creationParams = <String, dynamic>{};
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // return PlatformViewLink(
      //   viewType: viewType,
      //   // layoutDirection: TextDirection.ltr,
      //   // creationParams: creationParams,
      //   // creationParamsCodec: const StandardMessageCodec(),
      //   surfaceFactory:
      //       (BuildContext context, PlatformViewController controller) {

      //     return AndroidViewSurface(
      //       controller: controller as AndroidViewController,
      //       hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      //       gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      //     );
      //   },
      //   onCreatePlatformView: (PlatformViewCreationParams params) {
      //     return PlatformViewsService.initExpensiveAndroidView(
      //       id: params.id,
      //       layoutDirection: TextDirection.ltr,
      //       viewType: params.viewType,
      //       creationParams: creationParams,
      //       creationParamsCodec: const StandardMessageCodec(),
      //     );
      //   },
      // );
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          print('object $id');
        },
      );
    }
    print('object ${Platform.operatingSystem}');
    return Container();
  }
}
