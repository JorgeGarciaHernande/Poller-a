import 'package:flutter/material.dart';
import '/Controladores/carrito_controller.dart';
import '/Vistas/compra.dart';

class CarritoPage extends StatefulWidget {
  final CarritoController carritoController;
  final String atendio; // Usuario que realiza la compra
  final String usuario;
  final String role;

  const CarritoPage({
    required this.carritoController,
    required this.atendio,
    required this.usuario,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  Future<void> _finalizarCompra() async {
    final productos = widget.carritoController.obtenerProductosSeleccionados();

    // Navegar a la página de Checkout
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          productos: productos,
          atendio: widget.atendio,
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
        title: const Text('Carrito de Compras'),
        backgroundColor: const Color.fromARGB(255, 255, 146, 21),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: widget.carritoController,
              builder: (context, _) {
                final productos = widget.carritoController.obtenerProductosSeleccionados();
                return productos.isEmpty
                    ? const Center(
                        child: Text('El carrito está vacío'),
                      )
                    : ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    producto['imagen'],
                                    width: 50, // Reduced width
                                    height: 50, // Reduced height
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    (loadingProgress.expectedTotalBytes ?? 1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, color: Colors.red);
                                    },
                                  ),
                                ),
                                title: Text(
                                  producto['nombreProducto'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Cantidad: ${producto['cantidad']}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '\$${(producto['precioProducto'] * producto['cantidad']).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, color: Colors.red),
                                          onPressed: () {
                                            widget.carritoController.disminuirCantidadProducto(index);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, color: Colors.green),
                                          onPressed: () {
                                            widget.carritoController.aumentarCantidadProducto(index);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            widget.carritoController.eliminarProductoDelCarrito(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                AnimatedBuilder(
                  animation: widget.carritoController,
                  builder: (context, _) {
                    return Text(
                      '\$${widget.carritoController.obtenerTotalCarrito().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finalizarCompra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text(
                  'Finalizar compra',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
