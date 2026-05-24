// Stub implementation of mobile_scanner for platforms that don't support it (Windows, Linux)
import 'package:flutter/material.dart';

class MobileScanner extends StatefulWidget {
  final Function(Capture)? onDetect;

  const MobileScanner({super.key, this.onDetect});

  @override
  State<MobileScanner> createState() => _MobileScannerState();
}

class _MobileScannerState extends State<MobileScanner> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'QR scanning is not supported on this platform.\nPlease use the manual import/export feature instead.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MobileScannerController {
  void dispose() {}
}

class Capture {
  final List<Barcode> barcodes;

  Capture({required this.barcodes});
}

class Barcode {
  final String? rawValue;

  Barcode({this.rawValue});
}
