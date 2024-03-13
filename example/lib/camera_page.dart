import 'package:barcode_scan_custom/barcode_scan_custom.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Page'),
        actions: [
          IconButton(
            onPressed: controller?.flash,
            icon: const Icon(Icons.flash_on),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraWidget(
              // flashInit: true,
              created: (c) => setState(() => controller = c),
            ),
          ),
          if (controller != null)
            ValueListenableBuilder(
              valueListenable: controller!.barcodeLst,
              builder: (_, values, __) {
                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    itemBuilder: (_, i) {
                      final item = values[i];
                      final text = 'format: ${item.format}, formatNote:'
                          ' ${item.formatNote}, rawContent: '
                          '${item.rawContent}, type: ${item.type},';
                      return Text(text);
                    },
                    itemCount: values.length,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
