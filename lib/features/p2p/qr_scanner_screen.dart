import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/p2p/p2p_sync_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                isScanning = !isScanning;
                if (isScanning) {
                  controller.start();
                } else {
                  controller.stop();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onBarcodeDetect,
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: QrScannerOverlayPainter(
                    borderColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isScanning
                  ? const Text('Scanning for QR codes...')
                  : const Text('Scanning paused'),
            ),
          ),
        ],
      ),
    );
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null && isScanning) {
      _handleQRCode(barcode.rawValue!);
    }
  }

  Future<void> _handleQRCode(String qrCode) async {
    // Stop scanning to prevent multiple reads
    setState(() {
      isScanning = false;
    });
    controller.stop();

    // Validate that this looks like a peer ID
    if (_isValidPeerId(qrCode)) {
      final syncService = ref.read(p2pSyncServiceProvider);

      try {
        await syncService.connectToPeer(qrCode);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connecting to peer: $qrCode'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to P2P screen
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid QR code. Please scan a valid Pacey Peer ID.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Resume scanning after a short delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isScanning = true;
    });
    controller.start();
  }

  bool _isValidPeerId(String peerId) {
    // Basic validation - peer IDs should be alphanumeric and reasonable length
    return peerId.isNotEmpty &&
        peerId.length >= 8 &&
        peerId.length <= 50 &&
        RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(peerId);
  }
}

class QrScannerOverlayPainter extends CustomPainter {
  final Color borderColor;

  QrScannerOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final cutOutSize = 250.0;
    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw the overlay with transparent center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cutOutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw the border corners
    final borderLength = 30.0;
    final borderRadius = 10.0;

    // Top left corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cutOutRect.left - 5,
          cutOutRect.top - 5,
          borderLength,
          10,
        ),
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Top right corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cutOutRect.right - borderLength + 5,
          cutOutRect.top - 5,
          borderLength,
          10,
        ),
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cutOutRect.left - 5,
          cutOutRect.bottom - 5,
          borderLength,
          10,
        ),
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cutOutRect.right - borderLength + 5,
          cutOutRect.bottom - 5,
          borderLength,
          10,
        ),
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Request camera permission before showing QR scanner
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}
