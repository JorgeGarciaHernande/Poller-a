import 'package:flutter/material.dart';
import '/Controladores/Ventascontrolador.dart'; 

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  _VentaPageState createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  final VentaService _ventaService = VentaService();
  
  // Lista de productos para la venta (se puede reemplazar con datos reales)
  final List<Map<String, dynamic>> _productos = [
    {'id': '1', 'nombre': 'Platillo 1', 'precio': 50.0, 'imagen': 'https://via.placeholder.com/150'},
    {'id': '2', 'nombre': 'Platillo 2', 'precio': 60.0, 'imagen': 'https://via.placeholder.com/150'},
    {'id': '3', 'nombre': 'Platillo 3', 'precio': 40.0, 'imagen': 'https://via.placeholder.com/150'},
    {'id': '4', 'nombre': 'Platillo 4', 'precio': 30.0, 'imagen': 'https://via.placeholder.com/150'},
  ];

  String? _productoSeleccionado;
  int _cantidad = 1;
  double _precio = 0.0;

  // Función para abrir el cuadro de diálogo para ingresar cantidad y proceder con la venta
  Future<void> _abrirDialogoVenta(Map<String, dynamic> producto) async {
    _productoSeleccionado = producto['nombre'];
    _precio = producto['precio'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realizar Venta'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Producto: ${producto['nombre']}'),
            const SizedBox(height: 8),
            Text('Precio: \$${producto['precio'].toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            // Campo para ingresar cantidad
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _cantidad = int.tryParse(value) ?? 1;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Lógica para agregar la venta
              if (_productoSeleccionado != null && _cantidad > 0) {
                await _ventaService.agregarVenta(
                  nombreProducto: producto['nombre'],
                  precioProducto: producto['precio'],
                  cantidad: _cantidad,
                  idProducto: producto['id'],
                  nota: 'Venta realizada',
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venta realizada con éxito')),
                );
              }
            },
            child: const Text('Confirmar Venta'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Botón para realizar la venta (aún no tiene lógica)
            ElevatedButton(
              onPressed: () {
                // Lógica para realizar la venta
              },
              child: const Text('Realizar Venta'),
            ),
            const SizedBox(height: 16),

            // Cuadrícula de productos (platillos)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  return GestureDetector(
                    onTap: () {
                      _abrirDialogoVenta(producto);
                    },
                    child: Card(
                      color: Colors.yellow.shade200, // Color de fondo amarillo
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              producto['imagen'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            producto['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '\$${producto['precio'].toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green),
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
    );
  }
}
