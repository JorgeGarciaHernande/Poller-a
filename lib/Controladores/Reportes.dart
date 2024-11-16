import 'package:cloud_firestore/cloud_firestore.dart';

class ReporteController {
  final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');

  /// Obtener ventas del día
  Future<List<Map<String, dynamic>>> obtenerVentasDelDia() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDia = DateTime(now.year, now.month, now.day);
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDia)
          .where('fecha', isLessThan: inicioDia.add(const Duration(days: 1)))
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error al obtener ventas del día: $e");
      return [];
    }
  }

  /// Obtener ventas de la semana
  Future<List<Map<String, dynamic>>> obtenerVentasDeLaSemana() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioSemana = now.subtract(Duration(days: now.weekday - 1));
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioSemana)
          .where('fecha', isLessThan: inicioSemana.add(const Duration(days: 7)))
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error al obtener ventas de la semana: $e");
      return [];
    }
  }

  /// Obtener ventas del mes
  Future<List<Map<String, dynamic>>> obtenerVentasDelMes() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioMes = DateTime(now.year, now.month);
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioMes)
          .where('fecha', isLessThan: DateTime(now.year, now.month + 1))
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error al obtener ventas del mes: $e");
      return [];
    }
  }

  /// Calcular total vendido en un periodo de ventas
  double calcularTotalVendido(List<Map<String, dynamic>> ventas) {
    return ventas.fold(0.0, (sum, venta) => sum + (venta['totalVenta'] as double));
  }

  /// Generar datos para representación gráfica
  Map<String, double> generarDatosGrafica(List<Map<String, dynamic>> ventas) {
    Map<String, double> datos = {};
    for (var venta in ventas) {
      String producto = venta['nombreProducto'] as String;
      double totalVenta = (venta['totalVenta'] as double);

      if (datos.containsKey(producto)) {
        datos[producto] = datos[producto]! + totalVenta;
      } else {
        datos[producto] = totalVenta;
      }
    }
    return datos;
  }

  /// Cerrar caja
  Future<void> cerrarCaja() async {
    try {
      List<Map<String, dynamic>> ventasDelDia = await obtenerVentasDelDia();
      double totalDelDia = calcularTotalVendido(ventasDelDia);

      print("Caja cerrada. Total vendido hoy: \$${totalDelDia.toStringAsFixed(2)}");

      // Puedes agregar aquí la lógica para registrar el cierre de caja
      // en Firestore o en otro sistema.
    } catch (e) {
      print("Error al cerrar caja: $e");
    }
  }
}
