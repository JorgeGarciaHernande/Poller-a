import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polleriaproyecto/Controladores/carrito_controller.dart';
import 'package:polleriaproyecto/Vistas/carritoview.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
      precioProducto: (producto['precio'] as num).toDouble(), // Conversión explícita a double
      cantidad: 1,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['Nombre']} agregado al carrito')),
    );
  }

  void _mostrarCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarritoPage(
          carritoController: _carritoController,
          atendio: widget.usuario, // Usuario actual como el que atiende
          usuario: widget.usuario, // Pasar usuario
          role: widget.role, // Pasar rol
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getMensajeSegunHora()),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 146, 21),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _mostrarCarrito, // Botón para mostrar el carrito
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: const Color.fromARGB(255, 255, 146, 21),
            labelColor: const Color.fromARGB(255, 255, 146, 21),
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: 'Platillos'),
              Tab(text: 'Pollos'),
              Tab(text: 'Hamburguesas'),
              Tab(text: 'Adicionales'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGridProductos('Platillos'),
                _buildGridProductos('Pollos'),
                _buildGridProductos('Hamburguesas'),
                _buildGridProductos('Adicionales'),
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
          return const Center(child: Text('No hay productos disponibles.'));
        }

        final productos = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 4,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                      child: Image.network(
                        producto['imagen'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 146, 21),
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
