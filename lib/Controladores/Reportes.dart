import 'package:cloud_firestore/cloud_firestore.dart';

class ReporteController {
  final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');
  final CollectionReference ventasDiarias = FirebaseFirestore.instance.collection('ventas_diarias');

  /// Verificar o crear la colección `ventas_diarias` si no existe
  Future<void> verificarOCrearVentasDiarias() async {
    try {
      QuerySnapshot snapshot = await ventasDiarias.get();
      if (snapshot.docs.isEmpty) {
        print("La colección `ventas_diarias` está vacía. Inicializando...");
        await ventasDiarias.doc('ejemplo').set({
          'fecha': DateTime.now().toIso8601String(),
          'ganancia_total': 0.0,
          'productos': {},
        });
        print("Colección `ventas_diarias` inicializada.");
      } else {
        print("La colección `ventas_diarias` ya existe.");
      }
    } catch (e) {
      print("Error al verificar o crear la colección `ventas_diarias`: $e");
    }
  }

  /// Registrar las ventas del día en la colección `ventas_diarias`
  Future<void> registrarVentasDelDia() async {
    try {
      // Fecha actual
      DateTime now = DateTime.now();
      DateTime inicioDelDia = DateTime(now.year, now.month, now.day);

      // Obtener las ventas del día actual
      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDelDia)
          .get();

      double totalGanancias = 0.0;
      Map<String, int> productosVendidos = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalGanancias += (data['total'] as double? ?? 0.0);

        final carrito = data['carrito'] as List<dynamic>? ?? [];
        for (var item in carrito) {
          final nombreProducto = item['nombreProducto'] as String? ?? 'Desconocido';
          final cantidad = item['cantidad'] as int? ?? 0;

          productosVendidos[nombreProducto] =
              (productosVendidos[nombreProducto] ?? 0) + cantidad;
        }
      }

      // Registrar en `ventas_diarias`
      String fechaHoy = "${inicioDelDia.year}-${inicioDelDia.month.toString().padLeft(2, '0')}-${inicioDelDia.day.toString().padLeft(2, '0')}";
      await ventasDiarias.doc(fechaHoy).set({
        'fecha': fechaHoy,
        'ganancia_total': totalGanancias,
        'productos': productosVendidos,
      });

      print("Ventas del día registradas correctamente.");
    } catch (e) {
      print("Error al registrar ventas del día: $e");
    }
  }

  /// Obtener ganancias del día actual
  Future<double> obtenerGananciasDiaActual() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDelDia = DateTime(now.year, now.month, now.day);

      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDelDia)
          .get();

      double totalGanancias = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double? ?? 0.0);
      });

      return totalGanancias;
    } catch (e) {
      print("Error al obtener ganancias del día actual: $e");
      return 0.0;
    }
  }

  /// Obtener ganancias semanales (desde el lunes)
  Future<double> obtenerGananciasSemanales() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDeSemana = now.subtract(Duration(days: now.weekday - 1));
      DateTime inicioDia = DateTime(inicioDeSemana.year, inicioDeSemana.month, inicioDeSemana.day);

      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDia)
          .get();

      double totalGanancias = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double? ?? 0.0);
      });

      return totalGanancias;
    } catch (e) {
      print("Error al obtener ganancias semanales: $e");
      return 0.0;
    }
  }

  /// Obtener ganancias mensuales
  Future<double> obtenerGananciasMensuales() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDelMes = DateTime(now.year, now.month, 1);

      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDelMes)
          .get();

      double totalGanancias = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['total'] as double? ?? 0.0);
      });

      return totalGanancias;
    } catch (e) {
      print("Error al obtener ganancias mensuales: $e");
      return 0.0;
    }
  }

  /// Obtener ventas por día desde `ventas_diarias`
  Future<List<Map<String, dynamic>>> obtenerVentasPorDia() async {
    try {
      QuerySnapshot snapshot = await ventasDiarias.orderBy('fecha').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'fecha': data['fecha'] as String,
          'ganancia': data['ganancia_total'] as double? ?? 0.0,
        };
      }).toList();
    } catch (e) {
      print("Error al obtener ventas por día: $e");
      return [];
    }
  }

  /// Obtener productos más vendidos del día actual
  Future<Map<String, int>> obtenerProductosDelDiaActual() async {
    try {
      DateTime now = DateTime.now();
      DateTime inicioDelDia = DateTime(now.year, now.month, now.day);

      QuerySnapshot snapshot = await ventas
          .where('fecha', isGreaterThanOrEqualTo: inicioDelDia)
          .get();

      Map<String, int> productos = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final carrito = data['carrito'] as List<dynamic>? ?? [];

        for (var item in carrito) {
          final nombreProducto = item['nombreProducto'] as String? ?? 'Desconocido';
          final cantidad = item['cantidad'] as int? ?? 0;

          productos[nombreProducto] = (productos[nombreProducto] ?? 0) + cantidad;
        }
      }

      return productos;
    } catch (e) {
      print("Error al obtener productos del día actual: $e");
      return {};
    }
  }
}
