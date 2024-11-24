import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference usuarios = FirebaseFirestore.instance.collection('usuarios');

  Future<String?> verificarUsuario(String username, String password) async {
    try {
      QuerySnapshot querySnapshot = await usuarios
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // Usuario no encontrado
      }

      var userDoc = querySnapshot.docs.first;
      if (userDoc['password'] == password) {
        return userDoc['role']; // Devuelve el rol del usuario
      } else {
        return null; // Contraseña incorrecta
      }
    } catch (e) {
      print("Error al verificar usuario: $e");
      return null;
    }
  }
}
