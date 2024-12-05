import 'package:cloud_firestore/cloud_firestore.dart';

class MenuController {
  final CollectionReference menuCollection =
      FirebaseFirestore.instance.collection('menu');

  // Agregar una nueva comida al menú
  Future<void> agregarComida({
    required String nombre,
    required double precio,
    required String categoria,
    String? imagenPath,
  }) async {
    try {
      await menuCollection.add({
        'Nombre': nombre,
        'precio': precio,
        'categoria': categoria,
        'imagen': imagenPath ?? 'assets/placeholder.png',
      });
      print('Comida agregada exitosamente al menú.');
    } catch (e) {
      print('Error al agregar comida al menú: $e');
    }
  }

  // Obtener comidas por categoría
  Stream<QuerySnapshot> obtenerComidasPorCategoria(String categoria) {
    try {
      return menuCollection
          .where('categoria', isEqualTo: categoria)
          .snapshots();
    } catch (e) {
      print('Error al obtener comidas: $e');
      rethrow;
    }
  }

  // Editar una comida existente
  Future<void> editarComida({
    required String id,
    required String nombre,
    required double precio,
    required String categoria,
    String? imagenPath,
  }) async {
    try {
      await menuCollection.doc(id).update({
        'Nombre': nombre,
        'precio': precio,
        'categoria': categoria,
        'imagen': imagenPath ?? 'assets/placeholder.png',
      });
      print('Comida actualizada exitosamente.');
    } catch (e) {
      print('Error al actualizar comida: $e');
    }
  }

  // Eliminar una comida del menú
  Future<void> eliminarComida(String id) async {
    try {
      await menuCollection.doc(id).delete();
      print('Comida eliminada exitosamente del menú.');
    } catch (e) {
      print('Error al eliminar comida: $e');
    }
  }
}
