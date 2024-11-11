import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference usuarios = FirebaseFirestore.instance.collection('usuarios');

  // Función para verificar el inicio de sesión
  Future<bool> verificarUsuario(String username, String password) async {
    try {
      // Consulta el documento donde el campo 'username' coincide con el ingresado
      QuerySnapshot querySnapshot = await usuarios.where('username', isEqualTo: username).limit(1).get();

      // Si no encuentra ningún documento, el usuario no existe
      if (querySnapshot.docs.isEmpty) {
        print("Usuario no encontrado");
        return false;
      }

      // Si encuentra el usuario, revisa la contraseña
      var userDoc = querySnapshot.docs.first;
      String storedPassword = userDoc['password'];

      if (storedPassword == password) {
        print("Inicio de sesión exitoso");
        return true;
      } else {
        print("Contraseña incorrecta");
        return false;
      }
    } catch (e) {
      print("Error al verificar usuario: $e");
      return false;
    }
  }
}
