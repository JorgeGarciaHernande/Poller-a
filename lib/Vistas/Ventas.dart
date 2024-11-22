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
    List<Map<String, dynamic>> productos = await _ventaController.obtenerProductosDesdeInventario();
    setState(() {
      _productosInventario = productos;
    });
  }

  Future<void> _confirmarVenta() async {
    await _ventaController.confirmarVenta();
    setState(() {
      _carrito.clear(); // Vaciar el carrito después de confirmar la venta
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta confirmada exitosamente')),
    );
  }

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    final TextEditingController cantidadController = TextEditingController();
    final TextEditingController notaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${producto['Nombre']} al carrito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notaController,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              int cantidad = int.tryParse(cantidadController.text) ?? 1;
              String nota = notaController.text.trim();

              if (cantidad > 0) {
                setState(() {
                  _ventaController.agregarProductoTemporal(
                    idProducto: producto['id'],
                    nombreProducto: producto['Nombre'],
                    precioProducto: producto['precio'],
                    cantidad: cantidad,
                    nota: nota,
                  );
                  _carrito.add({
                    'idProducto': producto['id'],
                    'nombreProducto': producto['Nombre'],
                    'precioProducto': producto['precio'],
                    'cantidad': cantidad,
                    'nota': nota,
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Venta'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Lista de productos del inventario
          Expanded(
            flex: 2,
            child: _productosInventario.isNotEmpty
                ? ListView.builder(
                    itemCount: _productosInventario.length,
                    itemBuilder: (context, index) {
                      final producto = _productosInventario[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Image.network(
                            producto['imagen'] ?? 'https://via.placeholder.com/150',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(producto['Nombre']),
                          subtitle: Text('\$${producto['precio'].toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              _agregarAlCarrito(producto);
                            },
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const Divider(),
          // Carrito de compras
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  'Carrito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: _carrito.isNotEmpty
                      ? ListView.builder(
                          itemCount: _carrito.length,
                          itemBuilder: (context, index) {
                            final producto = _carrito[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(producto['nombreProducto']),
                                subtitle: Text(
                                  'Cantidad: ${producto['cantidad']}\nNota: ${producto['nota'].isEmpty ? "Sin nota" : producto['nota']}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _ventaController.eliminarProductoTemporal(index);
                                      _carrito.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('Carrito vacío')),
                ),
              ],
            ),
          ),
          // Botón para confirmar la venta
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _carrito.isNotEmpty
                  ? _confirmarVenta
                  : null, // Deshabilitar si el carrito está vacío
              child: const Text('Confirmar Venta'),
            ),
          ),
        ],
      ),
    );
  }
}
