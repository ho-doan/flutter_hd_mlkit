import 'dart:developer';

import 'package:barcode_scan_custom_example/camera_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runZonedGuarded(
      () {
        WidgetsFlutterBinding.ensureInitialized();
        runApp(const MaterialApp(home: CameraPage()));
      },
      (error, stack) => log(error.toString()),
    );
