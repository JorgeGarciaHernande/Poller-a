import 'package:flutter/material.dart';
import '/Controladores/Reportes.dart';

class ReportePage extends StatefulWidget {
  const ReportePage({super.key});

  @override
  _ReportePageState createState() => _ReportePageState();
}

class _ReportePageState extends State<ReportePage> {
  final ReporteController _reporteController = ReporteController();

  double _ventasDiarias = 0.0;
  double _ventasSemanales = 0.0;
  double _ventasMensuales = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    double diarias = await _reporteController.obtenerTotalVentasDiarias();
    double semanales = await _reporteController.obtenerTotalVentasSemanales();
    double mensuales = await _reporteController.obtenerTotalVentasMensuales();

    setState(() {
      _ventasDiarias = diarias;
      _ventasSemanales = semanales;
      _ventasMensuales = mensuales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes de Ventas"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ventas diarias
            Card(
              child: ListTile(
                title: const Text("Ventas Diarias"),
                subtitle: Text("\$${_ventasDiarias.toStringAsFixed(2)}"),
              ),
            ),
            const SizedBox(height: 10),

            // Ventas semanales
            Card(
              child: ListTile(
                title: const Text("Ventas Semanales"),
                subtitle: Text("\$${_ventasSemanales.toStringAsFixed(2)}"),
              ),
            ),
            const SizedBox(height: 10),

            // Ventas mensuales
            Card(
              child: ListTile(
                title: const Text("Ventas Mensuales"),
                subtitle: Text("\$${_ventasMensuales.toStringAsFixed(2)}"),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para cerrar caja
            ElevatedButton(
              onPressed: () async {
                await _reporteController.cerrarCaja();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Caja cerrada exitosamente.")),
                );
                _cargarReportes(); // Recargar los reportes después de cerrar caja
              },
              child: const Text("Cerrar Caja"),
            ),
          ],
        ),
      ),
    );
  }
}
