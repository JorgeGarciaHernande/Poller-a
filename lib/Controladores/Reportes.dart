import 'package:cloud_firestore/cloud_firestore.dart';

class ReporteController {
  final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');

  /// Obtener total de ventas diarias
  Future<double> obtenerTotalVentasDiarias() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDelDia = DateTime(now.year, now.month, now.day);
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDelDia)
          .get();

      double totalVentas = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double? ?? 0.0);
      });

      return totalVentas;
    } catch (e) {
      print("Error al obtener total de ventas diarias: $e");
      return 0.0;
    }
  }

  /// Obtener total de ventas semanales
  Future<double> obtenerTotalVentasSemanales() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDeSemana = now.subtract(Duration(days: now.weekday - 1));
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDeSemana)
          .get();

      double totalVentas = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double? ?? 0.0);
      });

      return totalVentas;
    } catch (e) {
      print("Error al obtener total de ventas semanales: $e");
      return 0.0;
    }
  }

  /// Obtener total de ventas mensuales
  Future<double> obtenerTotalVentasMensuales() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDelMes = DateTime(now.year, now.month, 1);
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDelMes)
          .get();

      double totalVentas = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double? ?? 0.0);
      });

      return totalVentas;
    } catch (e) {
      print("Error al obtener total de ventas mensuales: $e");
      return 0.0;
    }
  }

  /// Obtener datos para la gráfica
  Future<List<Map<String, dynamic>>> obtenerDatosParaGrafica() async {
    try {
      QuerySnapshot snapshot = await ventas.get();

      // Mapear productos y sus cantidades
      Map<String, int> conteoProductos = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final carrito = data['carrito'] as List<dynamic>;

        for (var producto in carrito) {
          final nombreProducto = producto['nombreProducto'] as String? ?? 'Desconocido';
          final cantidad = producto['cantidad'] as int? ?? 0;

          if (conteoProductos.containsKey(nombreProducto)) {
            conteoProductos[nombreProducto] = conteoProductos[nombreProducto]! + cantidad;
          } else {
            conteoProductos[nombreProducto] = cantidad;
          }
        }
      }

      return conteoProductos.entries
          .map((entry) => {
                'producto': entry.key,
                'cantidad': entry.value,
              })
          .toList();
    } catch (e) {
      print("Error al obtener datos para la gráfica: $e");
      return [];
    }
  }

  /// Cerrar caja y obtener el total del día
  Future<void> cerrarCaja() async {
    try {
      double total = await obtenerTotalVentasDiarias();
      print("Caja cerrada. Total del día: \$${total.toStringAsFixed(2)}");
      // Aquí podrías registrar el total en otra colección si lo necesitas
    } catch (e) {
      print("Error al cerrar caja: $e");
    }
  }
}
