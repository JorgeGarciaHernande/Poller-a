import 'package:cloud_firestore/cloud_firestore.dart';

class VentaService {
  final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');

  // Función para agregar una venta a Firestore
  Future<void> agregarVenta({
    required String nombreProducto,
    required double precioProducto,
    required int cantidad,
    required String idProducto,
    required String nota,
  }) async {
    try {
      double totalVenta = precioProducto * cantidad;

      await ventas.add({
        'nombreProducto': nombreProducto,
        'precioProducto': precioProducto,
        'cantidad': cantidad,
        'totalVenta': totalVenta,
        'idProducto': idProducto,
        'nota': nota,
        'fecha': FieldValue.serverTimestamp(), // Marca la fecha de la venta
      });

      print("Venta agregada exitosamente.");
    } catch (e) {
      print("Error al agregar venta: $e");
    }
  }

  // Función para obtener todas las ventas de Firestore
  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    try {
      QuerySnapshot snapshot = await ventas.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error al obtener ventas: $e");
      return [];
    }
  }
}
