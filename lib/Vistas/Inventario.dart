import 'package:flutter/material.dart';
import '/Controladores/Inventario_controlador.dart'; // Asegúrate de que la ruta sea correcta
import 'Ventas.dart'; // Importa la vista de ventas

class InventarioPage extends StatefulWidget {
  final String usuario;
  final String role;

  const InventarioPage({Key? key, required this.usuario, required this.role})
      : super(key: key);

  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _usarCantidadController = TextEditingController();
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

  // Función para abrir el cuadro de diálogo para agregar un producto
  Future<void> _abrirDialogoAgregarProducto() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Producto'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
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
              if (_nombreController.text.isNotEmpty &&
                  _precioController.text.isNotEmpty &&
                  _imageUrlController.text.isNotEmpty) {
                await _inventoryService.agregarProducto(
                  nombre: _nombreController.text,
                  cantidad: int.tryParse(_precioController.text) ?? 0,
                  imageUrl: _imageUrlController.text,
                );
                _nombreController.clear();
                _precioController.clear();
                _imageUrlController.clear();
                _cargarProductos(); // Recarga productos después de agregar
                Navigator.of(context).pop();
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
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // Función para abrir el cuadro de diálogo para añadir al inventario
  Future<void> _abrirDialogoAgregarProductoInventario() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Producto al Inventario'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad por lote',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
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
              if (_nombreController.text.isNotEmpty &&
                  _cantidadController.text.isNotEmpty &&
                  _imageUrlController.text.isNotEmpty) {
                await _inventoryService.agregarProducto(
                  nombre: _nombreController.text,
                  cantidad: int.tryParse(_cantidadController.text) ?? 0,
                  imageUrl: _imageUrlController.text,
                );
                _nombreController.clear();
                _cantidadController.clear();
                _imageUrlController.clear();
                _cargarProductos(); // Recarga productos después de agregar
                Navigator.of(context).pop();
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
    _cargarProductos(); // Recarga productos después de eliminar
  }

  // Función para usar una cantidad del producto
  Future<void> _usarProducto(String id, int cantidadActual) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usar Producto'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usarCantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad a usar',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_usarCantidadController.text.isNotEmpty) {
                int cantidadUsar =
                    int.tryParse(_usarCantidadController.text) ?? 0;
                int nuevaCantidad = cantidadActual - cantidadUsar;
                if (nuevaCantidad >= 0) {
                  await _inventoryService.usarProducto(
                    id: id,
                    cantidadUsar: cantidadUsar,
                  );
                  _usarCantidadController.clear();
                  _cargarProductos(); // Recarga productos después de usar
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cantidad inexistente, favor verificar')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, ingresa una cantidad')),
                );
              }
            },
            child: const Text('Usar'),
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

  // Muestra opciones para editar, eliminar o usar un producto
  void _mostrarOpcionesProducto(
      String id, String nombre, int cantidad, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones del Producto'),
        content: const Text('¿Qué deseas hacer con este producto?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _abrirDialogoEditarProducto(id, nombre, cantidad, imageUrl);
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usarProducto(id, cantidad);
            },
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }

  // Función para abrir el cuadro de diálogo para editar un producto
  Future<void> _abrirDialogoEditarProducto(
      String id, String nombre, int cantidad, String? imageUrl) async {
    _nombreController.text = nombre;
    _cantidadController.text = cantidad.toString();
    _imageUrlController.text = imageUrl ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad por lote',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
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
              if (_nombreController.text.isNotEmpty &&
                  _cantidadController.text.isNotEmpty &&
                  _imageUrlController.text.isNotEmpty) {
                await _inventoryService.editarProducto(
                  id: id,
                  nombre: _nombreController.text,
                  cantidad: int.tryParse(_cantidadController.text) ?? 0,
                  imageUrl: _imageUrlController.text,
                );
                _nombreController.clear();
                _cantidadController.clear();
                _imageUrlController.clear();
                _cargarProductos(); // Recarga productos después de editar
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, completa todos los campos')),
                );
              }
            },
            child: const Text('Guardar'),
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 146, 21),
        flexibleSpace: SafeArea(
          child: Container(
            color: const Color.fromARGB(255, 255, 146, 21),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Inventario',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 48), // To balance the space taken by the back button
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                              item['cantidad'] ?? 0,
                              item['imagen'],
                            );
                          },
                          child: Stack(
                            children: [
                              Card(
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
                                      'Cantidad: ${(item['cantidad'] ?? 0).toString()}',
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                              // Corrección: Null check para 'item['cantidad']'
                              if (item['cantidad'] != null &&
                                  item['cantidad'] <= 10 &&
                                  item['cantidad'] > 0)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.red.withOpacity(0.7),
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      'Producto casi agotado, hay ${item['cantidad']} unidades',
                                      style:
                                          const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              if (item['cantidad'] != null &&
                                  item['cantidad'] == 0)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.red.withOpacity(0.7),
                                    padding: const EdgeInsets.all(4.0),
                                    child: const Text(
                                      'Producto agotado',
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No hay productos")),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _abrirDialogoAgregarProducto,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                            Ventas(usuario: widget.usuario, role: widget.role),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Ir a Ventas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _abrirDialogoAgregarProductoInventario,
              icon: const Icon(Icons.add_box),
              label: const Text('Añadir Producto al Inventario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
