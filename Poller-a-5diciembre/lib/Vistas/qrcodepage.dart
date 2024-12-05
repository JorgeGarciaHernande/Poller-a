import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  final String deviceId;

  const QrCodePage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR del Dispositivo'),
      ),
      body: Center(
        child: QrImageView(
          data: deviceId,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
