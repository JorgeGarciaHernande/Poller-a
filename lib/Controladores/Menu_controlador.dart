import 'package:flutter/material.dart';
import '/Vistas/Ventas.dart'; // Asegúrate de tener esta vista creada
import '/Vistas/Dispositivos.dart'; // Asegúrate de tener esta vista creada
import '/Vistas/Inventario.dart'; // Asegúrate de tener esta vista creada
import '/Vistas/Reportesvista.dart'; // Asegúrate de tener esta vista creada

class MenuController {
  // Función para navegar a la vista de administración de empleados
  void irAAdministrarEmpleados(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DispositivosPage()),
    );
  }

  // Función para navegar a la vista de ventas
  void irAVentas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VentaPage()),
    );
  }

  // Función para navegar a la vista de inventario
  void irAInventario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventarioPage()),
    );
  }

  // Función para navegar a la vista de reportes
  void irAReportes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportePage()),
    );
  }
}
