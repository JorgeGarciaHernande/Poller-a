import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioController {
  final CollectionReference usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  /// Obtener todos los usuarios desde Firestore
  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      QuerySnapshot snapshot = await usuarios.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Agregar ID del documento
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener usuarios: $e");
      return [];
    }
  }

  /// Agregar un nuevo usuario a Firestore
  Future<void> agregarUsuario({
    required String username,
    required String password,
    required String rol, // Campo para el rol
  }) async {
    try {
      await usuarios.add({
        'username': username,
        'password': password,
        'rol': rol,  // Guardar el rol
      });
      print("Usuario agregado exitosamente.");
    } catch (e) {
      print("Error al agregar usuario: $e");
    }
  }

  /// Editar un usuario existente en Firestore
  Future<void> editarUsuario(String docId, {
    required String username,
    required String password,
    required String rol, // Campo para el rol
  }) async {
    try {
      await usuarios.doc(docId).update({
        'username': username,
        'password': password,
        'rol': rol, // Actualizar el rol
      });
      print("Usuario editado exitosamente.");
    } catch (e) {
      print("Error al editar usuario: $e");
    }
  }

  /// Eliminar un usuario desde Firestore
  Future<void> eliminarUsuario(String docId) async {
    try {
      await usuarios.doc(docId).delete();
      print("Usuario eliminado exitosamente.");
    } catch (e) {
      print("Error al eliminar usuario: $e");
    }
  }

  /// Buscar usuarios por nombre de usuario
  Future<List<Map<String, dynamic>>> buscarUsuario(String username) async {
    try {
      QuerySnapshot snapshot = await usuarios
          .where('username', isEqualTo: username)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Agregar ID del documento
        return data;
      }).toList();
    } catch (e) {
      print("Error al buscar usuario: $e");
      return [];
    }
  }
}
