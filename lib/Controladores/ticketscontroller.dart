import 'package:cloud_firestore/cloud_firestore.dart';

class TicketsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método para leer todos los tickets de la colección 'ventas'
  Future<List<Map<String, dynamic>>> leerTickets() async {
    try {
      final querySnapshot = await _firestore.collection('ventas').get();

      // Convertir los documentos a una lista de mapas
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Validar que los campos esenciales existan y procesar datos de carrito
        return {
          'id': doc.id, // ID del documento
            'atendio': data['atendio'] ?? 'No especificado',
          'total': data['total'] ?? 0.0,
          'fecha': data['fecha'] ?? Timestamp.now(),
          'metodoDePago': data['metodoDePago'] ?? 'Desconocido',
          'carrito': _procesarCarrito(data['carrito']),
        };
      }).toList();
    } catch (e) {
      print('Error al leer los tickets: $e');
      throw Exception('Error al obtener los tickets: $e');
    }
  }

  /// Método para eliminar un ticket específico por su ID
  Future<void> eliminarTicket(String idTicket) async {
    try {
      await _firestore.collection('ventas').doc(idTicket).delete();
      print('Ticket eliminado correctamente: $idTicket');
    } catch (e) {
      print('Error al eliminar el ticket: $e');
      throw Exception('Error al eliminar el ticket: $e');
    }
  }

  /// Procesar el carrito para asegurar datos correctos
  List<Map<String, dynamic>> _procesarCarrito(dynamic carrito) {
    if (carrito is List<dynamic>) {
      return carrito.map((producto) {
        if (producto is Map<String, dynamic>) {
          return {
            'nombreProducto': producto['nombreProducto'] ?? 'Producto Desconocido',
            'cantidad': producto['cantidad'] ?? 0,
            'precioProducto': producto['precioProducto'] ?? 0.0,
            'subtotal': producto['subtotal'] ?? 0.0,
          };
        } else {
          return {
            'nombreProducto': 'Producto Desconocido',
            'cantidad': 0,
            'precioProducto': 0.0,
            'subtotal': 0.0,
          };
        }
      }).toList();
    } else {
      return []; // Si no es una lista, devolvemos una lista vacía
    }
  }
}
