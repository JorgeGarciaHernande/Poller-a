import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart'; // Para la autenticación biométrica
import 'package:shared_preferences/shared_preferences.dart'; // Para guardar el token localmente
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
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

  Future<void> _checkBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      // Si hay token, intentar autenticación biométrica
      bool authenticated = false;
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'Autentíquese con su huella digital para continuar',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      } on PlatformException catch (e) {
        debugPrint('Error de autenticación: $e');
      }

      if (authenticated) {
        // Si la autenticación es exitosa, navegar directamente al menú
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketsMenu(role: 'user', usuario: 'Usuario'), // Ajusta según tu lógica
          ),
        );
        return;
      }
    }

    // Si no hay token o la autenticación falla, mostrar LoginPage después de un tiempo
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
          'https://img3.wallspic.com/previews/9/3/9/4/1/114939/114939-lea-ceniza-hogar-x750.jpg', // Imagen del pollo
          width: 200,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
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

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

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
      // Genera un token ficticio (en una app real deberías obtenerlo del servidor)
      final token = 'faketoken12345'; 
      await _saveToken(token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsMenu(role: role, usuario: username),
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
                  'https://img3.wallspic.com/previews/9/3/9/4/1/114939/114939-lea-ceniza-hogar-x750.jpg',
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
