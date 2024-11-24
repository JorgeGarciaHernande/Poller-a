import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Vistas/loginview.dart'; // Asegúrate de tener esta vista creada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Verificar o crear la colección necesaria para las ventas diarias
  await verificarOCrearVentasDiarias();

  // Crear usuarios (administrador y empleado) si no existen
  await crearUsuariosPredeterminados();

  runApp(const MainApp(autorizado: true));
}

class MainApp extends StatelessWidget {
  final bool autorizado;

  const MainApp({super.key, required this.autorizado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: autorizado
          ? const LoginPage() // Cambiado a la clase LoginPage
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

// Función para crear usuarios predeterminados (admin y empleado)
Future<void> crearUsuariosPredeterminados() async {
  try {
    CollectionReference usuarios =
        FirebaseFirestore.instance.collection('usuarios');

    // Verificar y crear usuario administrador
    QuerySnapshot adminSnapshot = await usuarios
        .where('username', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (adminSnapshot.docs.isEmpty) {
      print("Creando usuario administrador...");
      await usuarios.add({
        'username': 'admin',
        'password': 'admin123', // Cambia esta contraseña según tu preferencia
        'role': 'admin',
      });
      print("Usuario administrador creado con éxito.");
    } else {
      print("El usuario administrador ya existe.");
    }

    // Verificar y crear usuario empleado
    QuerySnapshot empleadoSnapshot = await usuarios
        .where('username', isEqualTo: 'empleado')
        .limit(1)
        .get();

    if (empleadoSnapshot.docs.isEmpty) {
      print("Creando usuario empleado...");
      await usuarios.add({
        'username': 'empleado',
        'password': 'empleado123', // Cambia esta contraseña según tu preferencia
        'role': 'empleado',
      });
      print("Usuario empleado creado con éxito.");
    } else {
      print("El usuario empleado ya existe.");
    }
  } catch (e) {
    print("Error al crear usuarios predeterminados: $e");
  }
}
