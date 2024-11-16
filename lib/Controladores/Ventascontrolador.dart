import 'package:cloud_firestore/cloud_firestore.dart';

class VentaController {
  final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');
  final CollectionReference inventario = FirebaseFirestore.instance.collection('productos');
  final List<Map<String, dynamic>> _productosSeleccionados = [];

  /// Obtener productos directamente desde el inventario de Firestore
  Future<List<Map<String, dynamic>>> obtenerProductosDesdeInventario() async {
    try {
      QuerySnapshot snapshot = await inventario.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Agregar ID del documento
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener productos desde inventario: $e");
      return [];
    }
  }

  /// Agregar un producto temporalmente al carrito
  void agregarProductoTemporal({
    required String idProducto,
    required String nombreProducto,
    required double precioProducto,
    required int cantidad,
    String? nota,
  }) {
    _productosSeleccionados.add({
      'idProducto': idProducto,
      'nombreProducto': nombreProducto,
      'precioProducto': precioProducto,
      'cantidad': cantidad,
      'nota': nota ?? '',
    });
    print("Producto agregado temporalmente: $nombreProducto");
  }

  /// Eliminar un producto temporalmente del carrito
  void eliminarProductoTemporal(int index) {
    _productosSeleccionados.removeAt(index);
    print("Producto eliminado del carrito.");
  }

  /// Obtener lista temporal de productos seleccionados
  List<Map<String, dynamic>> obtenerProductosSeleccionados() {
    return _productosSeleccionados;
  }

  /// Confirmar y registrar la venta en Firestore
  Future<void> confirmarVenta() async {
    try {
      for (var producto in _productosSeleccionados) {
        double totalVenta = producto['precioProducto'] * producto['cantidad'];
        await ventas.add({
          'idProducto': producto['idProducto'],
          'nombreProducto': producto['nombreProducto'],
          'precioProducto': producto['precioProducto'],
          'cantidad': producto['cantidad'],
          'totalVenta': totalVenta,
          'nota': producto['nota'],
          'fecha': FieldValue.serverTimestamp(), // Fecha de la venta
        });
      }
      _productosSeleccionados.clear(); // Limpiar el carrito
      print("Venta confirmada y registrada exitosamente.");
    } catch (e) {
      print("Error al registrar la venta: $e");
    }
  }

  /// Obtener todas las ventas desde Firestore
  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    try {
      QuerySnapshot snapshot = await ventas.orderBy('fecha', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Agregar ID del documento
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener ventas: $e");
      return [];
    }
  }

  /// Editar una venta existente en Firestore
  Future<void> editarVenta({
    required String docId,
    required String nombreProducto,
    required double precioProducto,
    required int cantidad,
    String? nota,
  }) async {
    try {
      double totalVenta = precioProducto * cantidad;
      await ventas.doc(docId).update({
        'nombreProducto': nombreProducto,
        'precioProducto': precioProducto,
        'cantidad': cantidad,
        'totalVenta': totalVenta,
        'nota': nota ?? '',
      });
      print("Venta editada exitosamente.");
    } catch (e) {
      print("Error al editar venta: $e");
    }
  }

  /// Eliminar una venta desde Firestore
  Future<void> eliminarVenta(String docId) async {
    try {
      await ventas.doc(docId).delete();
      print("Venta eliminada exitosamente.");
    } catch (e) {
      print("Error al eliminar venta: $e");
    }
  }

  /// Obtener un resumen de las ventas (por ejemplo, suma total de ventas)
  Future<double> obtenerResumenDeVentas() async {
    try {
      QuerySnapshot snapshot = await ventas.get();
      double totalVentas = snapshot.docs.fold(0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['totalVenta'] as double);
      });
      print("Resumen de ventas obtenido: $totalVentas");
      return totalVentas;
    } catch (e) {
      print("Error al obtener resumen de ventas: $e");
      return 0.0;
    }
  }

  /// Actualizar stock en el inventario después de una venta
  Future<void> actualizarInventario(String idProducto, int cantidadVendida) async {
    try {
      DocumentSnapshot snapshot = await inventario.doc(idProducto).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        int stockActual = data['stock'] ?? 0;

        // Actualizar stock solo si hay suficiente inventario
        if (stockActual >= cantidadVendida) {
          await inventario.doc(idProducto).update({
            'stock': stockActual - cantidadVendida,
          });
          print("Inventario actualizado para el producto $idProducto.");
        } else {
          print("Stock insuficiente para el producto $idProducto.");
        }
      } else {
        print("Producto con ID $idProducto no encontrado en el inventario.");
      }
    } catch (e) {
      print("Error al actualizar inventario: $e");
    }
  }
}
