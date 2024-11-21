import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Vistas/loginview.dart'; // Asegúrate de tener esta vista creada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Verificar si el dispositivo está autorizado
  // para ver la ventana de dispositivo no autorizado
  // quita el comentario de la siguiente línea y comenta la linea 15
  //bool autorizado = await verificarOCrearDispositivo();
  bool autorizado = true; // Cambiado para pruebas

  // Verificar o crear la colección necesaria para las ventas diarias
  await verificarOCrearVentasDiarias();

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
          ? const LoginPage() // Cambiado a la clase Menu
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
                     
                    ],
                  ),
                ),
              ),
            ), // Si no está autorizado, muestra un mensaje de error
    );
  }
}

// Función para verificar o crear el dispositivo en Firestore


// Función para verificar o crear la colección `ventas_diarias`
Future<void> verificarOCrearVentasDiarias() async {
  try {
    CollectionReference ventasDiarias =
        FirebaseFirestore.instance.collection('ventas_diarias');

    QuerySnapshot snapshot = await ventasDiarias.get();

    if (snapshot.docs.isEmpty) {
      print("La colección `ventas_diarias` está vacía. Inicializando...");
      await ventasDiarias.doc('ejemplo').set({
        'fecha': DateTime.now().toIso8601String(),
        'ganancia_total': 0.0,
        'productos': {},
      });
      print("Colección `ventas_diarias` inicializada.");
    } else {
      print("La colección `ventas_diarias` ya existe.");
    }
  } catch (e) {
    print("Error al verificar o crear la colección `ventas_diarias`: $e");
  }
}
