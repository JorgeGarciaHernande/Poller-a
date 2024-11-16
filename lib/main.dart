import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Controladores/AuthService.dart';
import 'Vistas/Menu.dart'; // Asegúrate de tener esta vista creada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Verificar si el dispositivo está autorizado
  bool autorizado = await verificarOCrearDispositivo();

  runApp(MainApp(autorizado: autorizado));
}

class MainApp extends StatelessWidget {
  final bool autorizado;

  const MainApp({super.key, required this.autorizado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: autorizado
          ? const Menu() // Cambiado a la clase Menu
          : const Scaffold(
              body: Center(
                child: Text(
                  "Dispositivo no autorizado",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ), // Si no está autorizado, muestra un mensaje de error
    );
  }
}

// Función para verificar o crear el dispositivo en Firestore
Future<bool> verificarOCrearDispositivo() async {
  final AuthService authService = AuthService();
  String deviceId = await authService.getOrCreateDeviceId();
  return await authService.verificarAutorizacion(deviceId);
}
