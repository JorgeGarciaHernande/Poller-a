import 'package:flutter/material.dart';
import '/Vistas/Ventas.dart'; // Asegúrate de tener esta vista creada
import '/Vistas/Dispositivos.dart'; // Asegúrate de tener esta vista creada
import '/Vistas/Inventario.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        centerTitle: true,
      ),
      body: Center( // Centra todo el contenido
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta el espacio de la columna para centrado vertical
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar a la vista de Administrar Empleados
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DispositivosPage()),
                );
              },
              child: const Text('Administrar Empleados'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la vista de Ventas
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VentaPage()),
                );
              },
              child: const Text('Ventas'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la vista de Inventario
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventarioPage()),
                );
              },
              child: const Text('Inventario'),
            ),
          ],
        ),
      ),
    );
  }
}
