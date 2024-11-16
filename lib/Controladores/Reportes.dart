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
        return sum + (data['totalVenta'] as double? ?? 0.0);
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
        return sum + (data['totalVenta'] as double? ?? 0.0);
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
        return sum + (data['totalVenta'] as double? ?? 0.0);
      });

      return totalVentas;
    } catch (e) {
      print("Error al obtener total de ventas mensuales: $e");
      return 0.0;
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
