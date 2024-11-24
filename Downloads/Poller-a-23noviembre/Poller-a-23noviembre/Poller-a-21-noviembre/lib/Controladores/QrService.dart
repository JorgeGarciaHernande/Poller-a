import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrService {
  /// Generates a QR Code widget for the given data.
  Widget generarQr(String data) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
