import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../my_widget/my_colors.dart';
import '../service/supabase_service.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final _service = SupabaseService();
  bool _isProcessing = false;
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Ticket"),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.white);
                  case TorchState.unavailable:
                    return const Icon(Icons.no_flash, color: Colors.grey);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (_isProcessing) return;
            if (barcode.rawValue == null) continue;

            final String code = barcode.rawValue!;

            setState(() => _isProcessing = true);

            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) =>
                const Center(child: CircularProgressIndicator()),
              );
            }

            final result = await _service.checkInAttendee(code);

            if (!mounted) return;
            Navigator.pop(context);

            await _showResultDialog(
              success: result['success'],
              message: result['message'],
              eventTitle: result['eventTitle'],
            );

            if (mounted) {
              setState(() => _isProcessing = false);
            }
          }
        },
      ),
    );
  }

  Future<void> _showResultDialog({
    required bool success,
    required String message,
    required String eventTitle,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: success ? Colors.green[50] : Colors.red[50],
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  success ? "Verified" : "Error",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const Text("Event:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              Text(
                eventTitle,
                style: TextStyle(
                  fontSize: 18,
                  color: MyColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}