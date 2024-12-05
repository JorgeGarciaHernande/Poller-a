import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Pollos Chava',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo dinámico
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: -50,
            child: _animatedCircle(200, Colors.orange.withOpacity(0.2)),
          ),
          Positioned(
            bottom: 50,
            right: -50,
            child: _animatedCircle(300, Colors.red.withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida personalizada
                Text(
                  '¡Hola, $usuario!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona una opción para comenzar:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemCount: _menuItems(context).length,
                      itemBuilder: (context, index) {
                        final item = _menuItems(context)[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildAnimatedButton(
                                context,
                                label: item['label'] as String,
                                icon: item['icon'] as IconData,
                                color: item['color'] as Color,
                                targetPage: item['targetPage'] as Widget,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _menuItems(BuildContext context) {
    return [
      {
        'label': 'Ventas',
        'icon': Icons.shopping_cart,
        'color': Colors.orangeAccent,
        'targetPage': Ventas(usuario: usuario, role: role),
      },
      if (role == 'admin')
        {
          'label': 'Menú',
          'icon': Icons.restaurant_menu,
          'color': Colors.deepOrangeAccent,
          'targetPage': comida(),
        },
      if (role == 'admin')
        {
          'label': 'Inventario',
          'icon': Icons.inventory,
          'color': Colors.redAccent,
          'targetPage': InventarioPage(usuario: usuario, role: role),
        },
      if (role == 'admin')
        {
          'label': 'Reportes',
          'icon': Icons.bar_chart,
          'color': Colors.teal,
          'targetPage': const ReportePage(),
        },
      if (role == 'admin')
        {
          'label': 'Usuarios',
          'icon': Icons.person,
          'color': Colors.blueAccent,
          'targetPage': const UsuarioPage(),
        },
      if (role == 'admin')
        {
          'label': 'Clientes',
          'icon': Icons.people,
          'color': Colors.purpleAccent,
          'targetPage': const ClientesPage(),
        },
      if (role == 'admin')
        {
          'label': 'Tickets',
          'icon': Icons.receipt_long,
          'color': Colors.pinkAccent,
          'targetPage': const TicketsPage(),
        },
    ];
  }

  Widget _buildAnimatedButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget targetPage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: MouseRegion(
        onEnter: (event) {
          // Puedes agregar efectos adicionales aquí.
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedCircle(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
