import 'package:barcode_scan_custom/barcode_scan_custom.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Page'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.flash_on),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: CameraWidget(),
    );
  }
}
