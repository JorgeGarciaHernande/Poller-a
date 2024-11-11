import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference usuarios = FirebaseFirestore.instance.collection('usuarios');

  // Función para verificar el inicio de sesión y ejecutar una acción en caso de éxito
  Future<bool> verificarUsuario(String username, String password, Function onSuccess) async {
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
        onSuccess(); // Llamada al callback en caso de éxito
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
