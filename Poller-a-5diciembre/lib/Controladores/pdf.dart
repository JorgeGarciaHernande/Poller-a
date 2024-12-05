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
    required idVenta,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado de la tienda
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Pollos Chava',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Av. Francisco Sarabia 1701, Ricardo Flores Magón',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      '89460 Cd Madero, Tamps.',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Sucursal: Zona Centro de Madero',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                  ],
                ),
              ),
              // Detalles del ticket
              pw.Text(
                'Comprobante de Venta',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Atendido por: $atendio'),
              pw.Text('Fecha: ${DateTime.now().toString().substring(0, 16)}'),
              pw.Text('Cliente: ${cliente?['nombre'] ?? 'No definido'}'),
              pw.Text(
                  'Teléfono: ${cliente?['numero_telefono'] ?? 'No definido'}'),
              pw.Text('Dirección: ${cliente?['direccion'] ?? 'No definido'}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              // Lista de productos
              pw.Text(
                'Productos:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(5),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Text('Producto',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Cant',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('P.U.',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Subtotal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...productos.map((producto) {
                    final subtotal =
                        producto['precioProducto'] * producto['cantidad'];
                    return pw.TableRow(
                      children: [
                        pw.Text(producto['nombreProducto']),
                        pw.Text('${producto['cantidad']}'),
                        pw.Text(
                            '\$${producto['precioProducto'].toStringAsFixed(2)}'),
                        pw.Text('\$${subtotal.toStringAsFixed(2)}'),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.Divider(),
              // Totales
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${total.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Pago: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${(total + cambio).toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cambio: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${cambio.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Método de Pago: $metodoDePago',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '¡Gracias por su preferencia!',
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
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
