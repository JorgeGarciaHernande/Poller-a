import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Vistas/Menu.dart';

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
    if (index >= 0 && index < _productosSeleccionados.length) {
      print("Producto eliminado del carrito: ${_productosSeleccionados[index]['nombreProducto']}");
      _productosSeleccionados.removeAt(index);
    }
  }

  /// Obtener lista temporal de productos seleccionados
  List<Map<String, dynamic>> obtenerProductosSeleccionados() {
    return List.from(_productosSeleccionados); // Devuelve una copia para evitar modificaciones directas
  }

  /// Confirmar y registrar la venta en Firestore
  Future<void> confirmarVenta({
    required BuildContext context,
    required String atendio,
    required String role,
    required String usuario,
    required String metodoDePago, // Parámetro para el método de pago
    String? direccionEntrega, // Nuevo parámetro para la dirección
  }) async {
    try {
      if (_productosSeleccionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay productos en el carrito.")),
        );
        return;
      }

      List<Map<String, dynamic>> carrito = [];
      double totalVenta = 0;
      String notaGeneral = "";

      for (var producto in _productosSeleccionados) {
        double subtotal = producto['precioProducto'] * producto['cantidad'];
        totalVenta += subtotal;

        carrito.add({
          'idProducto': producto['idProducto'],
          'nombreProducto': producto['nombreProducto'],
          'precioProducto': producto['precioProducto'],
          'cantidad': producto['cantidad'],
          'subtotal': subtotal,
          'nota': producto['nota'] ?? '',
        });

        if (producto['nota'] != null && producto['nota'].isNotEmpty) {
          notaGeneral += "${producto['nombreProducto']}: ${producto['nota']} \n";
        }
      }

      // Validar si la dirección es requerida para ventas de entrega
      if (direccionEntrega != null && direccionEntrega.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La dirección de entrega no puede estar vacía."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Registrar venta en Firestore, incluyendo el método de pago y la dirección si aplica
      await ventas.add({
        'carrito': carrito,
        'total': totalVenta,
        'notaGeneral': notaGeneral.trim(),
        'fecha': FieldValue.serverTimestamp(),
        'atendio': atendio,
        'metodoDePago': metodoDePago, // Registrar método de pago
        'direccionEntrega': direccionEntrega ?? '', // Registrar dirección si existe
        'usuario': usuario,
      });

      _productosSeleccionados.clear();
      print("Venta confirmada y registrada exitosamente.");

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Venta registrada exitosamente."),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsMenu (usuario: usuario, role: role),
        ),
      );
    } catch (e) {
      print("Error al registrar la venta: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error al registrar la venta."),
        backgroundColor: Colors.red,
      ));
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
      double totalVentas = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double);
      });
      print("Resumen de ventas obtenido: $totalVentas");
      return totalVentas;
    } catch (e) {
      print("Error al obtener resumen de ventas: $e");
      return 0.0;
    }
  }
}
