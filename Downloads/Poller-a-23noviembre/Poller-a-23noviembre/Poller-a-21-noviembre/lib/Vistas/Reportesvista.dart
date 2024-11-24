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

  double _gananciasDiaActual = 0.0;
  double _gananciasSemanales = 0.0;
  double _gananciasMensuales = 0.0;
  Map<String, int> _productosVendidos = {};
  List<Map<String, dynamic>> _ventasDiarias = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    double diaActual = await _reporteController.obtenerGananciasDiaActual();
    double semanales = await _reporteController.obtenerGananciasSemanales();
    double mensuales = await _reporteController.obtenerGananciasMensuales();
    Map<String, int> productos = await _reporteController.obtenerProductosDelDiaActual();
    List<Map<String, dynamic>> ventasDiarias = await _reporteController.obtenerVentasPorDia();

    setState(() {
      _gananciasDiaActual = diaActual;
      _gananciasSemanales = semanales;
      _gananciasMensuales = mensuales;
      _productosVendidos = productos;
      _ventasDiarias = ventasDiarias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes de Ventas"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjetas de ganancias
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCard("Ganancias Día Actual", _gananciasDiaActual),
                  _buildCard("Ganancias Semanales", _gananciasSemanales),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildCard("Ganancias Mensuales", _gananciasMensuales),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de productos vendidos
              const Text(
                "Productos más Vendidos Hoy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _productosVendidos.entries
                    .map((entry) => ListTile(
                          title: Text(entry.key),
                          trailing: Text("${entry.value} unidades"),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Gráfica de productos más vendidos
              const Text(
                "Gráfica de Productos Más Vendidos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _productosVendidos.isEmpty
                  ? const Center(child: Text("Cargando datos..."))
                  : SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          barGroups: _productosVendidos.entries
                              .map((entry) => BarChartGroupData(
                                    x: _productosVendidos.keys.toList().indexOf(entry.key),
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value.toDouble(),
                                        width: 20,
                                        color: _getBarColor(
                                            _productosVendidos.keys.toList().indexOf(entry.key)),
                                      ),
                                    ],
                                  ))
                              .toList(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false), // Sin números en el eje izquierdo
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < _productosVendidos.keys.length) {
                                    return Text(
                                      _productosVendidos.keys.elementAt(index),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
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
              const SizedBox(height: 16),

              // Tabla de ventas diarias
              const Text(
                "Historial de Ventas Diarias",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Fecha",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Ganancia",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ..._ventasDiarias.map((venta) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(venta['fecha']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("\$${venta['ganancia'].toStringAsFixed(2)}"),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String titulo, double monto) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
