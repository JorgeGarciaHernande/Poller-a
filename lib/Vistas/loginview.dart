import 'package:flutter/material.dart';
import '/Controladores/logincontrolador.dart'; // Importa el archivo de autenticación

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Variable para controlar el estado de carga

  Future<void> _iniciarSesion() async {
    setState(() {
      _isLoading = true; // Inicia la carga
    });

    String username = _usernameController.text;
    String password = _passwordController.text;
    bool loginExitoso = await _authService.verificarUsuario(username, password);

    setState(() {
      _isLoading = false; // Finaliza la carga
    });

    if (loginExitoso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inicio de sesión exitoso')),
      );
      // Aquí puedes redirigir a otra pantalla
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario o contraseña incorrectos')),
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
              decoration: InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator() // Muestra indicador de carga
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
