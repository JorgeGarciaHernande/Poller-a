import 'package:flutter/material.dart';
import '/Vistas/Ventas.dart';
import '/Vistas/comida.dart';
import '/Vistas/Reportesvista.dart';
import '/Vistas/Usuarios.dart';
import '/Vistas/Clientes.dart';
import '/Vistas/Ticketsview.dart';
import '/Vistas/Inventario.dart';

class TicketsMenu extends StatelessWidget {
  final String usuario;
  final String role;

  const TicketsMenu({super.key, required this.usuario, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pollos Chava'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.red],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              _buildMenuButton(
                context,
                label: 'Ventas',
                icon: Icons.shopping_cart,
                targetPage: Ventas(usuario: usuario, role: role),
              ),
              if (role == 'admin')
                _buildMenuButton(
                  context,
                  label: 'Menu',
                  icon: Icons.inventory,
                  targetPage: comida(),
                ),
              if (role == 'admin')
                _buildMenuButton(
                  context,
                  label: 'Inventario',
                  icon: Icons.inventory,
                  targetPage: InventarioPage(usuario: usuario, role: role),
                ),
              if (role == 'admin')
                _buildMenuButton(
                  context,
                  label: 'Reportes',
                  icon: Icons.bar_chart,
                  targetPage: const ReportePage(),
                ),
              if (role == 'admin')
                _buildMenuButton(
                  context,
                  label: 'Usuarios',
                  icon: Icons.person,
                  targetPage: const UsuarioPage(),
                ),
              if (role == 'admin')
                _buildMenuButton(
                  context,
                  label: 'Clientes',
                  icon: Icons.people,
                  targetPage: const ClientesPage(),
                ),
              if (role == 'admin')
                _buildMenuButton(
                  context,
                  label: 'Tickets',
                  icon: Icons.receipt_long, // Ícono de tickets
                  targetPage: const TicketsPage(),
                ),
            ],
          ),
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
