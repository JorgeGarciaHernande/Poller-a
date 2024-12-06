import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generarComprobanteDeVenta({
    required String atendio,
    required Map<String, dynamic>? cliente,
    required List<Map<String, dynamic>> productos,
    required double total,
    required double cambio,
    required String metodoDePago,
    required String idVenta, // Aseguramos que se incluya el ID del ticket
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Pollos Chava',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Av. Francisco Sarabia 1701, Ricardo Flores Magón\n89460 Cd Madero, Tamps.\nSucursal Zona Centro de Madero',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
              pw.Divider(),
              pw.Text('Ticket ID: $idVenta'),
              pw.Text('Atendido por: $atendio'),
              pw.Text('Método de pago: $metodoDePago'),
              pw.Divider(),
              pw.Text(
                'Productos Comprados:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              ...productos.map((producto) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${producto['nombreProducto']} x${producto['cantidad']}'),
                    pw.Text('\$${(producto['precioProducto'] * producto['cantidad']).toStringAsFixed(2)}'),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${total.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cambio:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${cambio.toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.Text(
                '¡Gracias por tu preferencia!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    // Mostrar el PDF en pantalla
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
