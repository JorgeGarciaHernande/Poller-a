import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Vistas/comida.dart';
import '/Vistas/Ventas.dart';
import '/Vistas/Inventario.dart';
import '/Vistas/Reportesvista.dart';
import '/Vistas/Usuarios.dart';
import '/Vistas/Clientes.dart';

class Menu extends StatefulWidget {
  final String username;

  const Menu({super.key, required this.username});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int? selectedIndex;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '¡Buenos días!';
    } else if (hour < 18) {
      return '¡Buenas tardes!';
    } else {
      return '¡Buenas noches!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'label': 'Ventas', 'icon': Icons.shopping_cart, 'page': const Ventas()},
      {'label': 'Inventario', 'icon': Icons.inventory, 'page': const InventarioPage()},
      {'label': 'Reportes', 'icon': Icons.bar_chart, 'page': const ReportePage()},
      {'label': 'Usuarios', 'icon': Icons.person, 'page': const UsuarioPage()},
      {'label': 'Clientes', 'icon': Icons.people, 'page': const ClientesPage()},
      {'label': 'Menú', 'icon': Icons.restaurant_menu, 'page': const comida()},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE28A), Color(0xFFFFA726)], // Amarillo claro a naranja
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Encabezado de bienvenida
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department, // Ícono relacionado con pollo asado
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '¡Bienvenido, ${widget.username}!\nQue deseas realizar.',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Grid de opciones
              Expanded(
                child: GridView.builder(
                  itemCount: menuItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          selectedIndex = index;
                        });

                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item['page']),
                        );

                        setState(() {
                          selectedIndex = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange.shade700 : Colors.amber.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'],
                              size: 48,
                              color: isSelected ? Colors.white : Colors.orange.shade900,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
