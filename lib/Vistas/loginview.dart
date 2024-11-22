import 'package:flutter/material.dart';
import '/Controladores/logincontrolador.dart'; // Importa el archivo de autenticación
import 'inventario.dart'; // Importa la vista de inventario

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Función para manejar el inicio de sesión
  Future<void> _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    // Llamamos a la función de autenticación y pasamos la navegación como callback
    bool loginExitoso = await _authService.verificarUsuario(
      username,
      password,
      () {
        // Navegar a la vista de inventario si el inicio de sesión es exitoso
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InventarioPage()),
        );
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (!loginExitoso) {
      // Mostrar mensaje de error si el inicio de sesión falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator() // Indicador de carga
                : ElevatedButton(
                    onPressed: _iniciarSesion,
                    child: const Text('Iniciar sesión'),
                  ),
          ],
        ),
      ),
    );
  }
}
