import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final CollectionReference productos =
      FirebaseFirestore.instance.collection('productos');

  // Función para agregar un nuevo producto a Firestore
  Future<void> agregarProducto({
    required String nombre,
    required int cantidad,
    String? imageUrl,
  }) async {
    try {
      await productos.add({
        'Nombre': nombre,
        'cantidad': cantidad,
        'id': await _obtenerNuevoId(),
        'imagen': imageUrl ??
            'https://via.placeholder.com/150', // Usa la URL proporcionada o una URL por defecto
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
    required int cantidad,
    String? imageUrl,
  }) async {
    try {
      await productos.doc(id).update({
        'Nombre': nombre,
        'cantidad': cantidad,
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

  // Función para usar una cantidad de un producto
  Future<void> usarProducto({
    required String id,
    required int cantidadUsar,
  }) async {
    try {
      DocumentSnapshot doc = await productos.doc(id).get();
      int cantidadActual = (doc.data() as Map<String, dynamic>)['cantidad'];
      int nuevaCantidad = cantidadActual - cantidadUsar;
      if (nuevaCantidad >= 0) {
        await productos.doc(id).update({
          'cantidad': nuevaCantidad,
        });
        print("Cantidad actualizada exitosamente.");
      } else {
        throw Exception("Cantidad inexistente.");
      }
    } catch (e) {
      print("Error al usar producto: $e");
    }
  }

  // Función privada para obtener un nuevo ID incremental
  Future<int> _obtenerNuevoId() async {
    final snapshot =
        await productos.orderBy('id', descending: true).limit(1).get();
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
