import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importar Font Awesome
import 'package:cloud_firestore/cloud_firestore.dart';
import '/Controladores/carrito_controller.dart';
import '/Vistas/carritoview.dart';

class Ventas extends StatefulWidget {
  final String usuario; // Usuario actual
  final String role; // Rol del usuario

  const Ventas({Key? key, required this.usuario, required this.role}) : super(key: key);

  @override
  _VentasState createState() => _VentasState();
}

class _VentasState extends State<Ventas> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CarritoController _carritoController = CarritoController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Incluye 5 pestañas
  }

  String _getMensajeSegunHora() {
    final horaActual = DateTime.now().hour;
    if (horaActual >= 6 && horaActual < 12) {
      return '¿Qué quieres para el desayuno?';
    } else if (horaActual >= 12 && horaActual < 18) {
      return '¿Qué quieres para el almuerzo?';
    } else {
      return '¿Qué quieres para la cena?';
    }
  }

  Stream<QuerySnapshot> _obtenerProductosPorCategoria(String categoria) {
    return _firestore
        .collection('menu')
        .where('categoria', isEqualTo: categoria)
        .snapshots();
  }

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    _carritoController.agregarProductoAlCarrito(
      idProducto: producto['id'],
      nombreProducto: producto['Nombre'],
      precioProducto: (producto['precio'] as num).toDouble(),
      cantidad: 1,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto['Nombre']} agregado al carrito'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarritoPage(
          carritoController: _carritoController,
          atendio: widget.usuario,
          usuario: widget.usuario,
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _getMensajeSegunHora(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 28),
            onPressed: _mostrarCarrito,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.orange.shade100,
            height: 80, // Ajustar altura para dar más espacio a los íconos
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black54,
              labelPadding: const EdgeInsets.symmetric(vertical: 10.0), // Más espacio vertical
              tabs: const [
                Tab(icon: Icon(Icons.restaurant, size: 28), text: 'Platillos'),
                Tab(
                  icon: FaIcon(
                    FontAwesomeIcons.drumstickBite, // Ícono de pierna de pollo
                    size: 28, // Ajustar tamaño del ícono
                  ),
                  text: 'Pollos',
                ),
                Tab(icon: Icon(Icons.fastfood, size: 28), text: 'Hamburguesas'),
                Tab(icon: Icon(Icons.food_bank, size: 28), text: 'Adicionales'),
                Tab(icon: Icon(Icons.local_offer, size: 28), text: 'Promociones'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGridProductos('Platillos'),
                _buildGridProductos('Pollos'),
                _buildGridProductos('Hamburguesas'),
                _buildGridProductos('Adicionales'),
                _buildGridProductos('Promociones'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridProductos(String categoria) {
    return StreamBuilder<QuerySnapshot>(
      stream: _obtenerProductosPorCategoria(categoria),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay productos disponibles.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final productos = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 3 / 4,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 6.0,
              shadowColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12.0),
                      ),
                      child: Image.network(
                        producto['imagen'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          producto['Nombre'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$${producto['precio'].toStringAsFixed(2)} MXN',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _agregarAlCarrito({
                            'id': productos[index].id,
                            'Nombre': producto['Nombre'],
                            'precio': producto['precio']
                          }),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
