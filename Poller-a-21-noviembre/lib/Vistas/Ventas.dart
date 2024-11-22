import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Controladores/carrito_controller.dart';
import 'package:polleriaproyecto/Vistas/carritoview.dart';
import '/Controladores/Ventascontrolador.dart';

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  _VentaPageState createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> with SingleTickerProviderStateMixin {
  final VentaController _ventaController = VentaController();
  final CarritoController _carritoController = CarritoController(); // Instanciamos el controlador del carrito
  List<Map<String, dynamic>> _productosInventario = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarProductosDesdeInventario();
  }

  Future<void> _cargarProductosDesdeInventario() async {
    try {
      List<Map<String, dynamic>> productos =
          await _ventaController.obtenerProductosDesdeInventario();
      setState(() {
        _productosInventario = productos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    _carritoController.agregarProductoAlCarrito(
      idProducto: producto['id'],
      nombreProducto: producto['Nombre'],
      precioProducto: producto['precio'],
      cantidad: 1, // Puedes ajustar la cantidad si es necesario
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
          carritoController: _carritoController, // Pasamos el controlador al carrito
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Venta'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 146, 21),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: 'Platillos'),
            Tab(text: 'Pollos'),
            Tab(text: 'Hamburguesas'),
            Tab(text: 'Adicionales'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _mostrarCarrito,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGridProductos(), // Vista para Platillos
          _buildGridProductos(), // Vista para Pollos
          _buildGridProductos(), // Vista para Hamburguesas
          _buildGridProductos(), // Vista para Adicionales
        ],
      ),
    );
  }

  Widget _buildGridProductos() {
    return Container(
      color: const Color.fromARGB(255, 255, 146, 21), // Fondo naranja claro
      child: Column(
        children: [
          // Productos en formato Grid
          Expanded(
            child: _productosInventario.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Dos columnas
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: _productosInventario.length,
                    itemBuilder: (context, index) {
                      final producto = _productosInventario[index];
                      return GestureDetector(
                        onTap: () => _agregarAlCarrito(producto),
                        child: Card(
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
                                    producto['imagen'] ??
                                        'https://via.placeholder.com/150',
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
                                      '\$${producto['precio'].toStringAsFixed(2)}', // Aquí cambiamos el símbolo
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => _agregarAlCarrito(producto),
                                      icon: const Icon(Icons.add_shopping_cart),
                                      label: const Text('Agregar'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
