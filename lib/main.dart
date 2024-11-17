import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Controladores/AuthService.dart';
import 'Vistas/Menu.dart'; // Asegúrate de tener esta vista creada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Verificar si el dispositivo está autorizado
  // para ver la ventana de dispositivo no autorizado
  // quita el comentario de la siguiente línea y comenta la linea 15
  //bool autorizado = await verificarOCrearDispositivo();
  bool autorizado = true; // Cambiado para pruebas

  runApp(MainApp(autorizado: autorizado));
}

class MainApp extends StatelessWidget {
  final bool autorizado;

  const MainApp({super.key, required this.autorizado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: autorizado
          ? const Menu() // Cambiado a la clase Menu
          : Scaffold(
              body: Container(
                color:
                    const Color.fromARGB(255, 250, 187, 14), // Fondo amarillo
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset('imagenes/logo pollos chava.png'),
                      ),
                      const SizedBox(
                          height: 20), // Espacio entre el cuadrado y el texto
                      const Text(
                        "Dispositivo no autorizado",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
