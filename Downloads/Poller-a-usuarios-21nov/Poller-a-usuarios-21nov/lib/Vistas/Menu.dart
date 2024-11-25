import 'package:flutter/material.dart';
import '/Vistas/Ventas.dart';

import '/Vistas/Inventario.dart';
import '/Vistas/Reportesvista.dart';
import '/Vistas/Usuarios.dart'; // Asegúrate de tener esta vista creada

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dos botones por fila
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildMenuButton(
              context,
              label: 'Ventas',
              icon: Icons.shopping_cart,
              targetPage: const VentaPage(),
            ),
            _buildMenuButton(
              context,
              label: 'Inventario',
              icon: Icons.inventory,
              targetPage: const InventarioPage(),
            ),
            _buildMenuButton(
              context,
              label: 'Reportes',
              icon: Icons.bar_chart,
              targetPage: const ReportePage(),
            ),
            _buildMenuButton(
              context,
              label: 'Usuarios',
              icon: Icons.person,
              targetPage: const UsuarioPage(), // Nueva vista
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Widget targetPage,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}