import 'package:flutter/material.dart';
import '/Vistas/Menu.dart';
import '/Controladores/logincontrolador.dart'; // Asegúrate de tener esta vista creada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pollería Proyecto',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Espera 5 segundos antes de navegar a la pantalla de Login
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.network(
          'https://scontent.ftam1-1.fna.fbcdn.net/v/t39.30808-6/304894260_6181916228504359_5480582647389094077_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=cc71e4&_nc_eui2=AeG-IzKi4tPSXKocZWJzW6cnN3RKNYxXfhk3dEo1jFd-GR5tquuxfWUySO8Fd0zD5MA7PnchGLEavw2L3s0dLnby&_nc_ohc=LwSAr99rY8AQ7kNvgGYtZFh&_nc_zt=23&_nc_ht=scontent.ftam1-1.fna&_nc_gid=Abg7HPSGKCY9_Urg__EA4F-&oh=00_AYD_U8IrzIB6jBF42wU5hYWISmrY4kN84TyevS4f9Vxrgg&oe=6746FFDF', // Imagen del pollo
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showLoginFields = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _onLoginPressed() {
    setState(() {
      _showLoginFields = true; // Muestra los campos de inicio de sesión
    });
  }

  Future<void> _validateUser() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, complete todos los campos.")),
      );
      return;
    }

    final role = await AuthService().verificarUsuario(username, password);

    if (role != null) {
      // Si el usuario es válido, navega a Menu y pasa los argumentos requeridos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsMenu (role: role, usuario: username),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario o contraseña incorrectos.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            height: _showLoginFields
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://scontent.ftam1-1.fna.fbcdn.net/v/t39.30808-6/304894260_6181916228504359_5480582647389094077_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=cc71e4&_nc_eui2=AeG-IzKi4tPSXKocZWJzW6cnN3RKNYxXfhk3dEo1jFd-GR5tquuxfWUySO8Fd0zD5MA7PnchGLEavw2L3s0dLnby&_nc_ohc=LwSAr99rY8AQ7kNvgGYtZFh&_nc_zt=23&_nc_ht=scontent.ftam1-1.fna&_nc_gid=Abg7HPSGKCY9_Urg__EA4F-&oh=00_AYD_U8IrzIB6jBF42wU5hYWISmrY4kN84TyevS4f9Vxrgg&oe=6746FFDF', // Imagen del pollo como fondo
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_showLoginFields)
                    ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      child: const Text("Log in"),
                    ),
                  if (_showLoginFields) ...[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _validateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      child: const Text("Ingresar"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
