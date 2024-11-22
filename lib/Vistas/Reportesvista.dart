import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<Map<String, dynamic>> _datosGrafica = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    double diarias = await _reporteController.obtenerTotalVentasDiarias();
    double semanales = await _reporteController.obtenerTotalVentasSemanales();
    double mensuales = await _reporteController.obtenerTotalVentasMensuales();
    List<Map<String, dynamic>> datosGrafica = await _reporteController.obtenerDatosParaGrafica();

    setState(() {
      _ventasDiarias = diarias;
      _ventasSemanales = semanales;
      _ventasMensuales = mensuales;
      _datosGrafica = datosGrafica;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de Ventas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard("Ventas Diarias", _ventasDiarias),
                _buildCard("Ventas Semanales", _ventasSemanales),
                _buildCard("Ventas Mensuales", _ventasMensuales),
              ],
            ),
            const SizedBox(height: 16),

            // Botón de Cerrar Caja
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _reporteController.cerrarCaja();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Caja cerrada exitosamente.")),
                  );
                  _cargarDatos(); // Recargar datos después de cerrar caja
                },
                child: const Text("Cerrar Caja"),
              ),
            ),
            const SizedBox(height: 16),

            // Gráfica de Productos más Vendidos
            const Text(
              "Productos más Vendidos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _datosGrafica.isEmpty
                  ? const Center(child: Text("Cargando datos..."))
                  : BarChart(
                      BarChartData(
                        barGroups: _datosGrafica
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value['cantidad'].toDouble(),
                                    width: 20,
                                    color: _getBarColor(entry.key), // Colores dinámicos
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Ocultar números de la izquierda
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _datosGrafica[value.toInt()]['producto'],
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return null; // Sin recuadros de valores
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para una tarjeta de información
  Widget _buildCard(String titulo, double monto) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "\$${monto.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función para asignar colores dinámicos a las barras
  Color _getBarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }
}
