import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Vistas/Menu.dart';
 
class MenuController {
  late String _username;

  // Método para establecer el nombre de usuario
  void setUsername(String username) {
    _username = username;
  }

  // Método para obtener el nombre de usuario
  String getUsername() {
    return _username;
  }

  // Método para navegar al menú pasando el usuario
  void irAMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Menu(username: _username),
      ),
    );
  }
}
