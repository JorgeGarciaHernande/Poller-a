import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Controladores/carrito_controller.dart';
import 'package:polleriaproyecto/Vistas/compra.dart';

class CarritoPage extends StatelessWidget {
  final CarritoController carritoController;

  const CarritoPage({
    required this.carritoController,
    Key? key,
  }) : super(key: key);

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
              animation: carritoController, // Para actualizar la vista en tiempo real
              builder: (context, _) {
                final productos = carritoController.obtenerProductosSeleccionados();
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
                                  borderRadius: BorderRadius.circular(8), // Bordes redondeados
                                  child: Image.network(
                                    producto['imagen'],
                                    width: 70, // Tamaño ajustado
                                    height: 70, // Tamaño ajustado
                                    fit: BoxFit.cover, // Ajusta la imagen sin distorsionar
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
                                      return const Icon(Icons.error, color: Colors.red); // Muestra un icono de error si la imagen no se carga
                                    },
                                  ),
                                ),
                                title: Text(
                                  producto['nombreProducto'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Cantidad: ${producto['cantidad']}'),
                                trailing: Column(
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
                                            carritoController.disminuirCantidadProducto(index);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, color: Colors.green),
                                          onPressed: () {
                                            carritoController.aumentarCantidadProducto(index);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            carritoController.eliminarProductoDelCarrito(index);
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
                  animation: carritoController,
                  builder: (context, _) {
                    return Text(
                      '\$${carritoController.obtenerTotalCarrito().toStringAsFixed(2)}',
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
                onPressed: () {
                  // Acción para finalizar compra: Navegar a la página de Checkout
                  final productos = carritoController.obtenerProductosSeleccionados();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(productos: productos),
                    ),
                  );
                },
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
