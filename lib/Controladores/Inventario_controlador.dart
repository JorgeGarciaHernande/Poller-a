import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final CollectionReference productos = FirebaseFirestore.instance.collection('productos');

  // Función para agregar un nuevo producto a Firestore
  Future<void> agregarProducto({
    required String nombre,
    required double precio,
    String? imageUrl,
  }) async {
    try {
      await productos.add({
        'Nombre': nombre,
        'precio': precio,
        'id': await _obtenerNuevoId(),
        'imagen': imageUrl ?? 'https://via.placeholder.com/150', // Usa la URL proporcionada o una URL por defecto
      });
      print("Producto agregado exitosamente con imagen.");
    } catch (e) {
      print("Error al agregar producto: $e");
    }
  }

  // Función para editar un producto en Firestore
  Future<void> editarProducto({
    required String id,
    required String nombre,
    required double precio,
    String? imageUrl,
  }) async {
    try {
      await productos.doc(id).update({
        'Nombre': nombre,
        'precio': precio,
        'imagen': imageUrl,
      });
      print("Producto editado exitosamente.");
    } catch (e) {
      print("Error al editar producto: $e");
    }
  }

  // Función para eliminar un producto de Firestore
  Future<void> eliminarProducto(String id) async {
    try {
      await productos.doc(id).delete();
      print("Producto eliminado exitosamente.");
    } catch (e) {
      print("Error al eliminar producto: $e");
    }
  }

  // Función privada para obtener un nuevo ID incremental
  Future<int> _obtenerNuevoId() async {
    final snapshot = await productos.orderBy('id', descending: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      int maxId = snapshot.docs.first['id'] as int;
      return maxId + 1;
    } else {
      return 1;
    }
  }

  // Función para obtener todos los productos desde Firestore
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    try {
      QuerySnapshot snapshot = await productos.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Añade el ID del documento al mapa
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener productos: $e");
      return [];
    }
  }
}
