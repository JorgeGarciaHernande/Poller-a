import 'package:flutter/material.dart';
import '/Controladores/logincontrolador.dart'; // Importa tu servicio de autenticación
import 'Menu.dart'; // Importa tu vista principal

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

    bool loginExitoso = await _authService.verificarUsuario(
      username,
      password,
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Menu()),
        );
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (!loginExitoso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen circular (puedes cambiar la URL)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://scontent.ftam1-1.fna.fbcdn.net/v/t39.30808-6/304880738_395517385989400_3153028245728482862_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=n20B4PFdXtYQ7kNvgFXi3Yb&_nc_zt=23&_nc_ht=scontent.ftam1-1.fna&_nc_gid=AgEm4oTaVKOcVo9W20esjIN&oh=00_AYAQZu5weLAQflgCv-wyNSovlN5lytPbntGbVEe6sntf8g&oe=6745EA99'), // URL de la imagen
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                // Campo de texto para usuario
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de texto para contraseña
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Botón de inicio de sesión
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
