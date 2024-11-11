import 'package:flutter/material.dart';
import '/Controladores/Inventario_controlador.dart'; // Asegúrate de que la ruta sea correcta
import 'dart:io';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  // Función para cargar productos desde Firestore
  Future<void> _cargarProductos() async {
    List<Map<String, dynamic>> productos = await _inventoryService.obtenerProductos();
    setState(() {
      _items = productos;
    });
  }

  // Función para seleccionar una imagen
  Future<void> _seleccionarImagen() async {
    File? imagen = await _inventoryService.seleccionarImagen();
    setState(() {
      _selectedImage = imagen;
    });
  }

  // Función para agregar un nuevo producto a Firestore
  Future<void> _agregarProducto() async {
    if (_nombreController.text.isNotEmpty && _precioController.text.isNotEmpty) {
      await _inventoryService.agregarProducto(
        nombre: _nombreController.text,
        precio: double.tryParse(_precioController.text) ?? 0.0,
        imagen: _selectedImage,
      );
      _nombreController.clear();
      _precioController.clear();
      setState(() {
        _selectedImage = null;
      });
      _cargarProductos(); // Recarga los productos después de agregar uno nuevo
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Formulario de entrada para agregar nuevo producto
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _seleccionarImagen,
                  child: const Text('Añadir Foto'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Vista previa de la imagen seleccionada
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _agregarProducto,
              child: const Text('Agregar Producto'),
            ),

            const SizedBox(height: 16),

            // Cuadrícula de productos
            Expanded(
              child: _items.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          color: Colors.yellow.shade200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.network(
                                  item['imagen'] ?? 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['Nombre'] ?? 'Producto sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '\$${(item['precio'] ?? 0.0).toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No hay productos")),
            ),
          ],
        ),
      ),
    );
  }
}
