import 'package:flutter/material.dart';
import '/Controladores/Inventario_controlador.dart'; // Asegúrate de que la ruta sea correcta
import 'Ventas.dart'; // Importa la vista de ventas

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  // Función para cargar productos desde Firestore
  Future<void> _cargarProductos() async {
    List<Map<String, dynamic>> productos =
        await _inventoryService.obtenerProductos();
    setState(() {
      _items = productos;
    });
  }

  // Función para abrir el cuadro de diálogo para ingresar el nombre, precio y URL de la imagen
  Future<void> _abrirDialogoAgregarProducto() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Producto'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo para nombre del producto
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Campo para precio
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            // Campo para URL de imagen
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de la imagen',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Verifica si todos los campos están llenos
              if (_nombreController.text.isNotEmpty &&
                  _precioController.text.isNotEmpty &&
                  _imageUrlController.text.isNotEmpty) {
                // Agregar producto
                await _inventoryService.agregarProducto(
                  nombre: _nombreController.text,
                  precio: double.tryParse(_precioController.text) ?? 0.0,
                  imageUrl: _imageUrlController.text,
                );
                _nombreController.clear();
                _precioController.clear();
                _imageUrlController.clear();
                setState(() {
                  _cargarProductos(); // Recargar productos después de agregar uno nuevo
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, completa todos los campos')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
          TextButton(
            onPressed: () {
              // Cerrar el diálogo sin agregar producto
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // Función para eliminar un producto
  Future<void> _eliminarProducto(String id) async {
    await _inventoryService.eliminarProducto(id);
    _cargarProductos();
  }

  // Muestra opciones para editar o eliminar un producto
  void _mostrarOpcionesProducto(
      String id, String nombre, double precio, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones del Producto'),
        content: const Text('¿Qué deseas hacer con este producto?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Aquí puedes añadir la funcionalidad de editar si lo necesitas
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarProducto(id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orangeAccent,
        flexibleSpace: SafeArea(
          child: Container(
            color: Colors.orangeAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Text(
                  'Inventario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 50,
                  height: 50,
                  child: Image.asset('imagenes/logo pollos chava.png'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Cuadrícula de productos
            Expanded(
              child: _items.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return GestureDetector(
                          onLongPress: () {
                            _mostrarOpcionesProducto(
                              item['id'],
                              item['Nombre'] ?? 'Producto sin nombre',
                              item['precio'] ?? 0.0,
                              item['imagen'],
                            );
                          },
                          child: Card(
                            color: Colors.yellow.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    item['imagen'] ??
                                        'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['Nombre'] ?? 'Producto sin nombre',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '\$${(item['precio'] ?? 0.0).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No hay productos")),
            ),
            const SizedBox(height: 8),
            // Botones para añadir producto e ir a ventas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _abrirDialogoAgregarProducto,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color de fondo
                    foregroundColor: Colors.white, // Color del texto
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const VentaPage()), // Navega a la vista de ventas
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Ir a Ventas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Color de fondo
                    foregroundColor: Colors.white, // Color del texto
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
