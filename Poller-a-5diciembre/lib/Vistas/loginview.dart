import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/Vistas/Menu.dart';
import '/Controladores/logincontrolador.dart';

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
    _checkForTokenAndAuthenticate();
  }

  Future<void> _checkForTokenAndAuthenticate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final usuarioGuardado = prefs.getString('usuario');
    final role = prefs.getString('role');

    if (token != null) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Por favor, autentíquese para continuar',
          options: const AuthenticationOptions(
            biometricOnly: true,
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TicketsMenu(
                role: role ?? 'user',
                usuario: usuarioGuardado ?? 'Usuario',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Falló la autenticación biométrica")),
          );
        }
      } on PlatformException catch (e) {
        print('Error de autenticación biométrica: ${e.message}');
      }
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.network(
          'https://scontent.ftam1-1.fna.fbcdn.net/v/t39.30808-6/304894260_6181916228504359_5480582647389094077_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=5Iz4iR-yDM8Q7kNvgE08WMg&_nc_zt=23&_nc_ht=scontent.ftam1-1.fna&_nc_gid=AZ9-K9YhcjksNZaYueFMt23&oh=00_AYDTtZTYbBQdJyfaVSihvUmVWla7mVVR6KM63jkhdSt3Aw&oe=6757425F',
          width: 200,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return const CircularProgressIndicator();
            }
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

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsuario = prefs.getString('usuario');

    if (savedUsuario != null) {
      setState(() {
        _usuarioController.text = savedUsuario;
      });
    }
  }

  Future<void> _saveCredentials(String token, String usuario, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('usuario', usuario);
    await prefs.setString('role', role);

    print('Token generado exitosamente: $token');
  }

  Future<void> _authenticateWithBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes una sesión guardada. Por favor, inicia sesión.")),
      );
      return;
    }

    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Autentíquese con su huella digital para continuar',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        final usuarioGuardado = prefs.getString('usuario');
        final roleGuardado = prefs.getString('role');

        print('Inicio de sesión biométrico exitoso');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketsMenu(
              role: roleGuardado ?? 'user',
              usuario: usuarioGuardado ?? 'Usuario',
            ),
          ),
        );
      } else {
        print('Falló la autenticación biométrica');
      }
    } on PlatformException catch (e) {
      print('Error en autenticación biométrica: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Elimina todos los datos guardados
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _onLoginPressed() {
    setState(() {
      _showLoginFields = true;
    });
  }

  Future<void> _validateUser() async {
    final username = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, complete todos los campos.")),
      );
      return;
    }

    final role = await AuthService().verificarUsuario(username, password);

    if (role != null) {
      await _saveCredentials(password, username, role);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsMenu(role: role, usuario: username),
        ),
      );
    } else {
      print('Falló la generación del token.');
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
            height: MediaQuery.of(context).size.height,
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
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint),
                      onPressed: _authenticateWithBiometrics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      label: const Text("Iniciar con huella"),
                    ),
                  if (!_showLoginFields)
                    ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Log in"),
                    ),
                  if (_showLoginFields) ...[
                    TextField(
                      controller: _usuarioController,
                      decoration: InputDecoration(
                        hintText: 'Usuario',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _validateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
