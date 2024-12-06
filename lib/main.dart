import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Vistas/loginview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Inicializa Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Verificar o crear la colección necesaria para las ventas diarias
    await verificarOCrearVentasDiarias();

    // Crear usuarios predeterminados (administrador y empleado) si no existen
    await crearUsuariosPredeterminados();

    // Ejecutar la aplicación
    runApp(const MainApp());
  } catch (e) {
    print("Error durante la inicialización de Firebase: $e");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Pantalla inicial: LoginPage
    );
  }
}

// Función para verificar o crear la colección `ventas_diarias`
Future<void> verificarOCrearVentasDiarias() async {
  try {
    final CollectionReference ventasDiarias =
        FirebaseFirestore.instance.collection('ventas_diarias');

    final QuerySnapshot snapshot = await ventasDiarias.get();

    if (snapshot.docs.isEmpty) {
      print("La colección `ventas_diarias` está vacía. Inicializando...");
      await ventasDiarias.doc('registro_inicial').set({
        'fecha': DateTime.now().toIso8601String(),
        'ganancia_total': 0.0,
        'productos': {},
      });
      print("Colección `ventas_diarias` inicializada correctamente.");
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
    final CollectionReference usuarios =
        FirebaseFirestore.instance.collection('usuarios');

    // Crear usuario administrador si no existe
    final QuerySnapshot adminSnapshot =
        await usuarios.where('username', isEqualTo: 'admin').limit(1).get();

    if (adminSnapshot.docs.isEmpty) {
      print("Creando usuario administrador...");
      await usuarios.add({
        'username': 'admin',
        'password': 'admin123', // Contraseña predeterminada
        'role': 'admin',
      });
      print("Usuario administrador creado con éxito.");
    } else {
      print("El usuario administrador ya existe.");
    }

    // Crear usuario empleado si no existe
    final QuerySnapshot empleadoSnapshot =
        await usuarios.where('username', isEqualTo: 'empleado').limit(1).get();

    if (empleadoSnapshot.docs.isEmpty) {
      print("Creando usuario empleado...");
      await usuarios.add({
        'username': 'empleado',
        'password': 'empleado123', // Contraseña predeterminada
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
