import 'package:flutter/material.dart';
import '/Controladores/Ventascontrolador.dart';

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  _VentaPageState createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  final VentaController _ventaController = VentaController();
  List<Map<String, dynamic>> _productosInventario = [];
  List<Map<String, dynamic>> _carrito = [];

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _carrito.add(producto);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['Nombre']} agregado al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Venta'),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 255, 146, 21), // Color de la AppBar
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 146, 21), // Fondo naranja claro
        child: Column(
          children: [
            // Productos en formato Grid
            Expanded(
              child: _productosInventario.isNotEmpty
                  ? GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        '\$${producto['precio'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
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
            if (_carrito.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('El carrito está vacío'),
              ),
          ],
        ),
      ),
    );
  }
}
