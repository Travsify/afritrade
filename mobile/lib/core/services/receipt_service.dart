import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/transaction_receipt.dart';

class ReceiptService {
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> shareReceipt(BuildContext context, Map<String, dynamic> transaction) async {
    try {
      // 1. Capture the widget as an image
      // Note: We use the ScreenshotController to capture a widget that isn't necessarily on screen
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        TransactionReceipt(transaction: transaction),
        context: context,
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        // 2. Save to temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/afritrad_receipt_${transaction['id']}.png').create();
        await imagePath.writeAsBytes(imageBytes);

        // 3. Share the file
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Afritrade Transaction Receipt: ${transaction['currency']} ${transaction['amount']}',
        );
      }
    } catch (e) {
      debugPrint("Share Receipt Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate receipt. Please try again.")),
        );
      }
    }
  }
}
